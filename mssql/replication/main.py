import json
import logging

import pandas as pd
import pymssql
import yaml
from neo4j import GraphDatabase

# 初始化日志
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

# 加载配置
def load_config(path="config.yml"):
    try:
        with open(path, "r") as f:
            return yaml.safe_load(f)
    except Exception as e:
        logging.error(f"Failed to load config file: {e}")
        raise

# 建立 SQL Server 连接
def connect_sql_server(config):
    server = config["server"]
    # port = config.get("port", "1433")
    database = config["database"]
    credientials = config.get("credientials", [])

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
            logging.info(f"Connected to {server}\{database} using user {user}")
            return conn
        except Exception as e:
            error_message = f"Failed to connect to {server}\{database} using user {user}: {e}"
            logging.error(error_message)
            continue
        
    return error_message

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
                pub.publisher_db AS SourceDatabase,
                pub.publication AS Publication,
                pub.description AS Description,
                art.article AS SourceTable,
                art.destination_object AS TargetTable,
                sub.subscriber_db AS TargetDatabase,
                s.srvname AS SubscriberServer,
                ss.srvname AS PublisherServer,
                CASE 
                    WHEN sub.status = 2 THEN 'active'
                    WHEN sub.status = 1 THEN 'subscribed'
                    WHEN sub.status = 0 THEN 'inactive'
                    ELSE 'unknown'
                END AS SyncStatus
            FROM
                distribution.dbo.MSpublications AS pub
            JOIN
                distribution.dbo.MSarticles AS art ON pub.publication_id = art.publication_id
            JOIN
                distribution.dbo.MSsubscriptions AS sub ON art.article_id = sub.article_id AND art.publication_id = sub.publication_id
            JOIN
                master.dbo.sysservers AS s ON sub.subscriber_id = s.srvid
            JOIN
                master.dbo.sysservers AS ss ON pub.publisher_id = ss.srvid
        """
        return pd.read_sql(query, conn)
    except Exception as e:
        logging.warning(f"Could not retrieve replication info: {e}")
        return pd.DataFrame()

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
            "s_server": s_server,
            "s_db": s_db,
            "t_server": t_server,
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

    config['server'] = server_name
    conn_or_error = connect_sql_server(config)

    if isinstance(conn_or_error, str):
        visited_servers[server_name] = conn_or_error
        logging.error(f"Cannot connect to {server_name}: {conn_or_error}")
        return

    conn = conn_or_error
    visited_servers[server_name] = conn

    try:
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
        dist_conn_or_error = connect_sql_server(config)
        
        if isinstance(dist_conn_or_error, str):
            visited_servers[distributor] = dist_conn_or_error
            logging.error(f"Cannot connect to distributor {distributor}: {dist_conn_or_error}")
            return
        
        visited_servers[distributor] = dist_conn_or_error
        df = get_replication_info(dist_conn_or_error)

        if df.empty:
            return
        
        grouped = df.groupby(["SourceDatabase", "SubscriberServer", "TargetDatabase"])
        for (src_db, tgt_srv, tgt_db), group in grouped:
            table_status_list = [
                {
                    "source": row["SourceTable"],
                    "target": row["TargetTable"],
                    "status": row["SyncStatus"],
                    "publication": row["Publication"], 
                    "description": row["Description"],
                }
                for _, row in group.iterrows()
            ]
            publisher_server = group.iloc[0]["PublisherServer"]  # 👈 从行中提取真实 Publisher
            
            # 统计各状态的数量
            status_counts = group["SyncStatus"].value_counts().to_dict()

            # 构造 extra 字典，平铺 status 统计
            extra = {
                "tables": json.dumps(table_status_list),
                **status_counts
            }
            graph.create_lineage(
                publisher_server, src_db,
                tgt_srv, tgt_db,
                "replication", extra
            )
            traverse_lineage(tgt_srv, config.copy(), graph, visited_servers)

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
            if isinstance(result, str):
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
