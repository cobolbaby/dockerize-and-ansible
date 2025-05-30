import logging

import pandas as pd
import pyodbc
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
        logging.error(f"Failed to load config: {e}")
        raise

# 建立 SQL Server 连接
def connect_sql_server(config):
    try:
        conn_str = f"DRIVER={config['driver']};SERVER={config['server']};DATABASE={config['database']};UID={config['uid']};PWD={config['pwd']}"
        return pyodbc.connect(conn_str)
    except Exception as e:
        logging.error(f"Failed to connect to SQL Server {config['server']}: {e}")
        raise

# 获取 Distributor 名称
def get_distributor_name(conn):
    try:
        cursor = conn.cursor()
        cursor.execute("EXEC sp_helpdistributor;")
        row = cursor.fetchone()
        return row.distributor if row else None
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
            ps.secondary_database
        FROM
            msdb.dbo.log_shipping_primary_databases AS p
        JOIN
            msdb.dbo.log_shipping_primary_secondaries AS ps ON p.primary_id = ps.primary_id;
        """
        return pd.read_sql(query, conn)
    except Exception as e:
        logging.warning(f"Could not retrieve log shipping info: {e}")
        return pd.DataFrame()

# 获取 Replication 信息
def get_replication_info(conn):
    try:
        query = """
        SELECT
            pub.publisher_db AS SourceDatabase,
            art.article AS SourceTable,
            sub.subscriber_db AS TargetDatabase,
            s.srvname AS SubscriberServer,
            CASE 
                WHEN sub.status = 2 THEN 'active'
                WHEN sub.status = 5 THEN 'inactive'
                ELSE 'unknown'
            END AS SyncStatus
        FROM
            MSpublications AS pub
        JOIN
            MSarticles AS art ON pub.publication_id = art.publication_id
        JOIN
            MSsubscriptions AS sub ON art.article_id = sub.article_id
        JOIN
            master.dbo.sysservers AS s ON sub.subscriber_id = s.srvid;
        """
        df = pd.read_sql(query, conn)
        if df.empty:
            return []

        grouped = []
        for (src_db, tgt_db, tgt_server), group in df.groupby(["SourceDatabase", "TargetDatabase", "SubscriberServer"]):
            tables = [
                {
                    "source_table": row["SourceTable"],
                    "target_table": row["SourceTable"],  # 默认目标表与源表同名
                    "status": row["SyncStatus"]
                }
                for _, row in group.iterrows()
            ]
            grouped.append({
                "SourceDatabase": src_db,
                "TargetDatabase": tgt_db,
                "SubscriberServer": tgt_server,
                "Tables": tables
            })
        return grouped
    except Exception as e:
        logging.warning(f"Could not retrieve replication info: {e}")
        return []


# 图数据库操作类
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
            logging.error(f"Failed to create lineage in Neo4j: {e}")

    @staticmethod
    def _create_and_link(tx, s_server, s_db, t_server, t_db, ltype, extra_props=None):
        query = """
        MERGE (src_srv:sqlserver:server {name: $s_server})
        MERGE (src_db:sqlserver:database {name: $s_server + '\\\\' + $s_db})<-[:HOSTS]-(src_srv)
        MERGE (tgt_srv:sqlserver:server {name: $t_server})
        MERGE (tgt_db:sqlserver:database {name: $t_server + '\\\\' + $t_db})<-[:HOSTS]-(tgt_srv)
        MERGE (src_db)-[r:REPLICATES_TO]->(tgt_db)
        SET r.type = $ltype
        SET r.extra_props = $extra_props
        """
        tx.run(query, s_server=s_server, s_db=s_db, t_server=t_server, t_db=t_db, ltype=ltype, extra_props=extra_props or [])


# 递归遍历数据血缘
def traverse_lineage(server_name, config, graph, visited_servers):
    if server_name in visited_servers:
        logging.info(f"Already visited: {server_name}")
        return
    visited_servers.add(server_name)

    try:
        config['server'] = server_name
        conn = connect_sql_server(config)

        log_shipping_df = get_log_shipping_info(conn)
        for _, row in log_shipping_df.iterrows():
            graph.create_lineage(
                source_server=row["primary_server"],
                source_db=row["primary_database"],
                target_server=row["secondary_server"],
                target_db=row["secondary_database"],
                lineage_type="log_shipping"
            )
            traverse_lineage(row["secondary_server"], config.copy(), graph, visited_servers)

        distributor_name = get_distributor_name(conn)
        if distributor_name:
            config['server'] = distributor_name
            config['database'] = 'distribution'
            dist_conn = connect_sql_server(config)
            replication_infos = get_replication_info(dist_conn)
            for info in replication_infos:
                graph.create_lineage(
                    source_server=server_name,
                    source_db=info["SourceDatabase"],
                    target_server=info["SubscriberServer"],
                    target_db=info["TargetDatabase"],
                    lineage_type="replication",
                    extra_props=info["Tables"]
                )
                traverse_lineage(info["SubscriberServer"], config.copy(), graph, visited_servers)

    except Exception as e:
        logging.error(f"Error during traversal for server {server_name}: {e}")

# 主函数
def main():
    try:
        config = load_config()
        sql_config = config["sql_server"]
        neo4j_config = config["neo4j"]

        graph = LineageGraph(**neo4j_config)
        visited_servers = set()
        traverse_lineage(sql_config['server'], sql_config.copy(), graph, visited_servers)
        graph.close()
        logging.info("Data lineage successfully recorded in Neo4j.")
    except Exception as e:
        logging.critical(f"Unhandled error in main(): {e}")

if __name__ == "__main__":
    main()
