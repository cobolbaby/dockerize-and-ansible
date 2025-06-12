import json
import logging

import pandas as pd
import pymssql
import yaml
from neo4j import GraphDatabase

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

# 优化连接建立时间
CONNECTION_POOL = {}

# 加载配置
def load_config(path="config.yml"):
    try:
        with open(path, "r") as f:
            return yaml.safe_load(f)
    except Exception as e:
        logging.error(f"Failed to load config file: {e}")
        raise

def connect_sql_server(config):
    server = config["server"]
    database = config["database"]
    credientials = config.get("credientials", [])

    signature = (server, database)
    if signature in CONNECTION_POOL:
        logging.info(f"Using cached connection for {server}\\{database}")
        return CONNECTION_POOL[signature]

    error_message = ""

    for crediential in credientials:
        user = crediential.get("user")
        password = crediential.get("password")

        try:
            conn = pymssql.connect(
                server=server,
                user=user,
                password=password,
                database=database,
                login_timeout=5
            )
            logging.info(f"Connected to {server}\\{database} using user {user}")
            CONNECTION_POOL[signature] = conn  # 存入缓存
            return conn
        except Exception as e:
            error_message = f"Failed to connect to {server}\\{database} using user {user}: {e}"
            logging.error(error_message)
            continue

    # 所有认证方式都失败后，抛出异常
    raise ConnectionError(error_message)

# 获取 Distributor 名称
def get_sql_server_distributor(conn):
    try:
        cursor = conn.cursor()
        cursor.execute("EXEC sp_helpdistributor;")
        row = cursor.fetchone()
        return row[0] if row else None
    except Exception as e:
        logging.warning(f"Could not get distributor name: {e}")
        return None

# 获取 Log Shipping 信息
def get_log_shipping_info(conn):
    try:
        query = """
            SELECT
                CAST(SERVERPROPERTY('ServerName') AS NVARCHAR(128)) AS primary_server,
                p.primary_database,
                ps.secondary_server,
                ps.secondary_database,
                '' AS status
            FROM
                msdb.dbo.log_shipping_primary_databases AS p
            JOIN
                msdb.dbo.log_shipping_primary_secondaries AS ps ON p.primary_id = ps.primary_id
        """
        return pd.read_sql(query, conn)
    except Exception as e:
        logging.warning(f"Could not retrieve log shipping info: {e}")
        return pd.DataFrame()

# 获取 Replication 信息（包含目标表名）
def get_replication_info(conn):
    try:
        query = """
            SELECT
				ss.srvname AS publisher,
				pub.publisher_db,
                pub.publication,
                CASE 
                    WHEN pub.publication_type = 2 THEN 'merge'
                    WHEN pub.publication_type = 1 THEN 'snapshot'
                    WHEN pub.publication_type = 0 THEN 'transactional'
                    ELSE 'unknown'
                END AS publication_type,
				pub.description,
                art.article AS src_table,
                s.srvname AS subscriber,
                sub.subscriber_db,
                CASE 
                    WHEN sub.subscription_type = 2 THEN 'anonymous'
                    WHEN sub.subscription_type = 1 THEN 'pull'
                    WHEN sub.subscription_type = 0 THEN 'push'
                    ELSE 'unknown'
                END AS subscription_type,
                art.destination_object AS dst_table,
                CASE 
                    WHEN sub.status = 2 THEN 'active'
                    WHEN sub.status = 1 THEN 'subscribed'
                    WHEN sub.status = 0 THEN 'inactive'
                    ELSE 'unknown'
                END AS sync_status
            FROM
                distribution.dbo.MSpublications AS pub
            JOIN
                distribution.dbo.MSarticles AS art ON pub.publication_id = art.publication_id
            JOIN
                distribution.dbo.MSsubscriptions AS sub ON art.article_id = sub.article_id AND art.publication_id = sub.publication_id
            JOIN
                distribution.dbo.MSreplservers AS s ON sub.subscriber_id = s.srvid
            JOIN
                distribution.dbo.MSreplservers AS ss ON pub.publisher_id = ss.srvid

            union all


              SELECT
				sub.publisher AS publisher,
				pub.publisher_db,
                pub.publication,
                CASE 
                    WHEN pub.publication_type = 2 THEN 'merge'
                    WHEN pub.publication_type = 1 THEN 'snapshot'
                    WHEN pub.publication_type = 0 THEN 'transactional'
                    ELSE 'unknown'
                END AS publication_type,
				pub.description,
                --art.article AS src_table,
                '' AS src_table,
				sub.subscriber,
                sub.subscriber_db,
                CASE 
                    WHEN sub.subscription_type = 2 THEN 'anonymous'
                    WHEN sub.subscription_type = 1 THEN 'pull'
                    WHEN sub.subscription_type = 0 THEN 'push'
                    ELSE 'unknown'
                END AS subscription_type,
                --art.destination_object AS dst_table,
                '' AS dst_table,
                CASE 
                    WHEN sub.status = 2 THEN 'deleted'
                    WHEN sub.status = 1 THEN 'active'
                    WHEN sub.status = 0 THEN 'inactive'
                    ELSE 'unknown'
                END AS sync_status
            FROM
                distribution.dbo.MSpublications AS pub
            LEFT JOIN
                distribution.dbo.MSarticles AS art ON pub.publication_id = art.publication_id
            JOIN
                distribution.dbo.MSmerge_subscriptions AS sub ON pub.publication_id = sub.publication_id -- art.article_id = sub.article_id AND 

        """
        return pd.read_sql(query, conn)
    except Exception as e:
        logging.warning(f"Could not retrieve replication info: {e}")
        return pd.DataFrame()

def drop_inactive_subscription(sub, config):
    """
    删除 inactive 状态的 replication（仅当 subscriber 在黑名单中）
    """
    publication = sub["publication"]
    publisher = sub["publisher"]
    publisher_db = sub["publisher_db"]
    subscriber = sub["subscriber"]
    subscriber_db = sub["subscriber_db"]

    if subscriber not in config["blacklist"]:
        return  # 不在黑名单，跳过

    logging.warning(
        f"Deleting inactive publication {publication} from {publisher}/{publisher_db} to subscriber {subscriber}/{subscriber_db}"
    )
    try:
        config['server'] = publisher
        # config['database'] = publisher_db
        conn = connect_sql_server(config)

        # https://github.com/MicrosoftDocs/sql-docs/blob/live/docs/relational-databases/replication/delete-a-push-subscription.md
        with conn.cursor() as cursor:
            sql = f"""
                USE [{publisher_db}];
                EXEC sp_dropsubscription 
                    @publication = N'{publication}', 
                    @subscriber = N'{subscriber}', 
                    @destination_db = N'{subscriber_db}'
                    -- @ignore_distributor = 1
                ;
            """
            logging.info(f"Executing SQL:\n{sql}")
            cursor.execute(sql)

        conn.commit()

        config['server'] = subscriber
        # config['database'] = subscriber_db
        conn = connect_sql_server(config)

        with conn.cursor() as cursor:
            sql = f"""
                USE [{subscriber_db}];
                EXEC sp_subscription_cleanup 
                    @publication = N'{publication}', 
                    @publisher = N'{publisher}', 
                    @publisher_db = N'{publisher_db}'
                ;
            """
            logging.info(f"Executing SQL:\n{sql}")
            cursor.execute(sql)

        conn.commit()

        logging.info(f"Deleted subscription {subscriber}/{subscriber_db} successfully.")
    except ConnectionError as e:
        logging.error(f"Failed to connect to {publisher}: {e}")
    except Exception as e:
        logging.error(f"Failed to delete subscription for {subscriber}/{subscriber_db}: {e}")

class LineageGraph:
    def __init__(self, uri, user, password):
        try:
            self.driver = GraphDatabase.driver(uri, auth=(user, password))
        except Exception as e:
            logging.error(f"Failed to connect to Neo4j: {e}")
            raise

    def close(self):
        self.driver.close()

    def create_lineage(self, source_server, source_db, target_server, target_db, lineage_type, extra_props=None):
        try:
            with self.driver.session() as session:
                session.execute_write(
                    self._create_and_link, source_server, source_db, target_server, target_db, lineage_type, extra_props
                )
        except Exception as e:
            logging.error(f"Failed to create lineage: {e}")

    def build_set_props(self, extra_props):
        return "\n".join([f"SET r.{k} = ${k}" for k in extra_props.keys()])

    def _create_and_link(self, tx, s_server, s_db, t_server, t_db, ltype, extra_props):
        if not ltype.isidentifier():
            raise ValueError(f"Invalid relationship type: {ltype}")  # 安全校验
        
        set_extra_props = self.build_set_props(extra_props)

        query = f"""
        MERGE (src_srv:sqlserver:server {{name: $s_server}})
        MERGE (src_db:sqlserver:database {{name: $s_server + '\\\\' + $s_db}})<-[:HOSTS]-(src_srv)

        MERGE (tgt_srv:sqlserver:server {{name: $t_server}})
        MERGE (tgt_db:sqlserver:database {{name: $t_server + '\\\\' + $t_db}})<-[:HOSTS]-(tgt_srv)

        MERGE (src_db)-[r:{ltype}]->(tgt_db)
        {set_extra_props}
        RETURN r
        """

        params = {
            "s_server": s_server.upper(),
            "s_db": s_db,
            "t_server": t_server.upper(),
            "t_db": t_db,
            "ltype": ltype,
            **extra_props  # flatten into query parameters
        }

        tx.run(query, **params)


# 遍历并记录数据血缘
def traverse_lineage(server_name, config, graph, visited_servers):
    if server_name in visited_servers:
        logging.info(f"Already visited: {server_name}")
        return

    try:
        config['server'] = server_name
        conn = connect_sql_server(config)

        visited_servers[server_name] = conn
        
        # Log shipping
        log_shipping_df = get_log_shipping_info(conn)
        for _, row in log_shipping_df.iterrows():
            extra = {
                "status": row["status"],
            }
            graph.create_lineage(
                row["primary_server"], row["primary_database"],
                row["secondary_server"], row["secondary_database"],
                "logshipping", extra
            )
            traverse_lineage(row["secondary_server"], config.copy(), graph, visited_servers)

        # Replication
        distributor = get_sql_server_distributor(conn)
        if distributor is None:
            return
        
        config['server'] = distributor
        # config['database'] = 'distribution'
        conn = connect_sql_server(config)
        
        visited_servers[distributor] = conn

        df = get_replication_info(conn)

        if df.empty:
            return
        
        # 筛选其中 inactive 状态的 replication，且判断 subscriber 是否在黑名单中，如果存在，只直接删除
        if config["blacklist"] is not None:
            inactive_df = df[df["sync_status"] == "inactive"]
            for _, sub in inactive_df.iterrows():
                drop_inactive_subscription(sub, config)
        
        grouped = df.groupby(["publisher", "publisher_db", "subscriber", "subscriber_db"])
        for (publisher, publisher_db, subscriber, subscriber_db), group in grouped:
            # 同步涉及的表
            table_status_list = group.to_dict(orient="records")
            
            # 统计各状态的数量
            status_counts = group["sync_status"].value_counts().to_dict()

            # 构造 extra 字典，平铺 status 统计
            extra = {
                "tables": json.dumps(table_status_list),
                **status_counts
            }

            graph.create_lineage(
                publisher, publisher_db,
                subscriber, subscriber_db,
                "replication", extra
            )

            traverse_lineage(subscriber, config.copy(), graph, visited_servers)

    except ConnectionError as e:
        visited_servers[server_name] = e

        logging.error(f"Failed to connect to {e}")
    except Exception as e:
        logging.error(f"Traversal error at server {server_name}: {e}")

# 主函数
def main():
    try:
        config = load_config()
        sql_config = config["sqlserver"]
        neo4j_config = config["neo4j"]

        visited = {}

        graph = LineageGraph(**neo4j_config)
        traverse_lineage(sql_config["server"], sql_config.copy(), graph, visited)
        graph.close()

        unreachable = []

        for srv, result in visited.items():
            if isinstance(result, ConnectionError):
                unreachable.append((srv, result))
            else:
                logging.info(f"{srv} processed successfully.")

        if unreachable:
            logging.warning("The following servers are unreachable:")
            for srv, reason in unreachable:
                logging.warning(f"{srv} unreachable: {reason}")

    except Exception as e:
        logging.critical(f"Critical failure in main(): {e}")

if __name__ == "__main__":
    main()
