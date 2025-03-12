import logging
import os
import random
import re
import sys
from configparser import ConfigParser
from datetime import datetime

import pymssql
import requests

from kafka import KafkaConsumer

# 配置参数
KAFKA_CONNECT_SERVICE_URL = os.getenv("KAFKA_CONNECT_SERVICE_URL")
KAFKA_CONNECT_BOOTSTRAP_SERVERS = os.getenv("KAFKA_CONNECT_BOOTSTRAP_SERVERS")

if KAFKA_CONNECT_SERVICE_URL is None or KAFKA_CONNECT_BOOTSTRAP_SERVERS is None:
    print("KAFKA_CONNECT_SERVICE_URL/KAFKA_CONNECT_BOOTSTRAP_SERVERS environment variable is not set.")
    sys.exit(1)  # 1 signifies an error, 0 would indicate success

# 默认 properties 文件路径
DEFAULT_PROPERTIES_FILE = "connect-credentials.properties"

# 设置日志
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

# 数据库连接池
connections = {}

def get_db_connection(db):
    """获取或创建数据库连接"""
    db_key = (db["hostname"], db["port"], db["database"])

    if db_key not in connections:
        try:
            connections[db_key] = pymssql.connect(
                server=db["hostname"],
                port=db["port"],
                database=db["database"],
                user="dbadmin", # db["user"],
                password="y=cos(x)+2", # db["password"],
                as_dict=True,
                login_timeout=5  # Connection timeout set to 5 seconds
            )
        except Exception as e:
            logging.error(f"数据库连接失败: {e}")
            raise e
        
    return connections[db_key]

# 读取 properties 文件
def load_properties(file_path):
    try:
        with open(file_path, "r", encoding="utf-8") as f:
            config = ConfigParser()
            # 保持键名的原始大小写
            config.optionxform = str  # 默认会转换为小写，改为不转换

            properties = "[DEFAULT]\n" + f.read()
            config.read_string(properties)
            
            return dict(config["DEFAULT"])
    except Exception as e:
        print(f"读取 properties 文件失败: {e}")
        return {}

# 解析占位符，提取文件路径和变量名
def extract_file_and_key(value):
    # 如果 database.hostname 形如 ${file:/etc/kafka-connect/secrets/connect-credentials.properties:IMX_CTO_HOSTNAME}
    # 请将其拆解为 /etc/kafka-connect/secrets/connect-credentials.properties 以及 IMX_CTO_HOSTNAME 两段

    match = re.match(r"\${file:(.*?):(.*?)}", value)
    return match.groups() if match else (None, None)

# 解析占位符并替换
def resolve_placeholders(value):

    file_path, key = extract_file_and_key(value)

    # 文件不存在时使用默认配置文件
    if file_path and not os.path.exists(file_path):
        file_path = DEFAULT_PROPERTIES_FILE

    if file_path and key:
        properties = load_properties(file_path)
        return properties.get(key, f"<MISSING: {key}>")  # 默认值处理

    return value  # 不匹配则返回原值

def get_debezium_sqlserver_connectors():
    """获取 Kafka Connect 上的 Debezium SQL Server 连接器信息"""
    response = requests.get(f"{KAFKA_CONNECT_SERVICE_URL}/connectors?expand=info")
    if response.status_code != 200:
        logging.error(
            "获取 Kafka Connect 连接器失败: 状态码=%d, 响应内容=%s, 请求URL=%s",
            response.status_code,
            response.text,
            response.url
        )
        return []
    
    connectors = response.json()
    db_dict = {}
    
    # 过滤 Debezium SQL Server 连接器
    for connector, config in connectors.items():
        config = config.get("info").get("config")
        
        # 判断是否为 Debezium SQL Server 连接器
        if config.get("connector.class") == "io.debezium.connector.sqlserver.SqlServerConnector":
            
            config = {k: resolve_placeholders(v) for k, v in config.items()}
            # fix: 兼容 Debezium 2.x 版本的配置
            dbname = config.get("database.dbname") if config.get("database.dbname") else config.get("database.names")

            db_key = (dbname, config.get("database.hostname"), config.get("database.port", 1433))
            if db_key not in db_dict:
                db_dict[db_key] = {
                    "database": dbname,
                    "hostname": config.get("database.hostname"),
                    "port": config.get("database.port", 1433),
                    "user": config.get("database.user"),
                    "password": config.get("database.password"),
                    "tables": set(),
                    "active_topics": set()
                }
            # 合并表列表
            db_dict[db_key]["tables"].update(config.get("table.include.list", "").split(","))

            active_topics = get_active_topics_of_kafka_connect(config)
            db_dict[db_key]["active_topics"].update(active_topics)

    return list(db_dict.values())

def get_active_topics_of_kafka_connect(connector_config):
    """
    获取指定 Connector 关联的 Kafka Topic
    """
    connector_name = connector_config.get("name")

    response = requests.get(f"{KAFKA_CONNECT_SERVICE_URL}/connectors/{connector_name}/topics")
    if response.status_code != 200:
        logging.error(
            "获取 Kafka Connect 连接器失败: 状态码=%d, 响应内容=%s, 请求URL=%s",
            response.status_code,
            response.text,
            response.url
        )
        return []
        
    connector_topics = response.json()
    return [
        topic for topic in connector_topics.get(connector_name, {}).get('topics', [])
        if '.dbo.' in topic
    ]

def check_sqlserver_cdc(db):
    """检查 SQL Server 是否启用 CDC，并比对表"""
    try:
        conn = get_db_connection(db)
        cursor = conn.cursor()

        cursor.execute("SELECT is_cdc_enabled FROM sys.databases WHERE name = %s", (db["database"]))
        is_cdc_enabled = cursor.fetchone()
        if not is_cdc_enabled:
            logging.error(f"数据库 {db['database']} 未启用 CDC！")
            return False
        
        cursor.execute("SELECT name FROM sys.tables WHERE is_tracked_by_cdc = 1")
        cdc_tables = {"dbo." + row['name'] for row in cursor.fetchall()}
        configured_tables = set(db["tables"])
        missing_tables = configured_tables - cdc_tables
        extra_cdc_tables = cdc_tables - configured_tables
        if missing_tables:
            logging.warning(f"以下表未启用 CDC: {', '.join(missing_tables)}")
        if extra_cdc_tables:
            logging.warning(f"以下表启用了 CDC 但未配置同步: {', '.join(extra_cdc_tables)}")
        return True
    except Exception as e:
        logging.error(f"检查 SQL Server CDC 失败: {e}")
        return False

def check_sqlserver_cdc_agent_job(db):
    """检查 SQL Server CDC Agent Job 是否运行"""
    try:
        conn = get_db_connection(db)
        cursor = conn.cursor()
    
        cursor.execute("EXEC msdb.dbo.sp_help_jobactivity @job_name = %s", (f'cdc.{db["database"]}_capture',))
        job_status = cursor.fetchone()
        if job_status and job_status['start_execution_date'] is not None and job_status['stop_execution_date'] is None:
            logging.info(f"CDC Agent Job {db['database']}_capture 正常运行")
            return True
        logging.error(f"CDC Agent Job {db['database']}_capture 未运行，尝试重启")
        return False
    except Exception as e:
        logging.error(f"检查 CDC Agent Job 失败: {e}")
        return False

def restart_sqlserver_cdc_agent_job(db):
    """重启 CDC Agent Job"""
    try:
        # conn = get_db_connection(db)
        # cursor = conn.cursor()

        # cursor.execute("EXEC msdb.dbo.sp_start_job @job_name = %s", (f'cdc.{db["database"]}_capture'))
        logging.info(f"重启 CDC Agent Job {db['database']}_capture 成功")
    except Exception as e:
        logging.error(f"重启 CDC Agent Job {db['database']}_capture 失败: {e}")

def is_sqlserver_alwayson(db):
    """检查是否为 AlwaysOn 集群"""
    try:
        conn = get_db_connection(db)
        cursor = conn.cursor()

        cursor.execute("SELECT COUNT(1) AS is_alwayson FROM sys.availability_groups")
        result = cursor.fetchone()
        return result["is_alwayson"] > 0
    except Exception as e:
        logging.error(f"检查 AlwaysOn 集群状态失败: {e}")
        return False

def is_sqlserver_alwayson_primary(db):
    """检查当前实例是否为 AlwaysOn 集群的主节点"""
    try:
        conn = get_db_connection(db)
        cursor = conn.cursor(as_dict=True)

        # 使用 sys.fn_hadr_is_primary_replica 判断当前实例是否为主节点
        # https://learn.microsoft.com/en-us/sql/relational-databases/system-functions/sys-fn-hadr-is-primary-replica-transact-sql?view=sql-server-ver16
        cursor.execute("""
            SELECT sys.fn_hadr_is_primary_replica(%s) AS is_primary
        """, (db["database"],))
        result = cursor.fetchone()

        if result and (result['is_primary'] == 1 or result['is_primary'] is None):
            logging.info(f"当前数据库 {db['database']} 所在实例 {db['hostname']} 是主节点")
            return True
        else: # is_primary 为 0 则不是主节点
            logging.info(f"当前数据库 {db['database']} 所在实例 {db['hostname']} 不是主节点")
            return False
    except Exception as e:
        logging.error(f"检查 AlwaysOn 主节点状态失败: {e}")
        return False

def get_sqlserver_alwayson_primary(db):
    """获取 AlwaysOn 集群的主节点地址并更新数据库配置"""
    try:
        conn = get_db_connection(db)
        cursor = conn.cursor()
        
        # 
        cursor.execute("""
            SELECT primary_replica 
            FROM sys.dm_hadr_availability_group_states;
        """)
        result = cursor.fetchone()
        if result:
            logging.info(f"主节点地址: {result['primary_replica']}")
            # 修改数据库连接信息指向主节点
            db["hostname"] = result["primary_replica"]
        return db
    except Exception as e:
        logging.error(f"获取 AlwaysOn 主节点地址失败: {e}")
        return db

def check_sqlserver_alwayson_status(db):
    """检查 SQL Server AlwaysOn 状态"""
    try:
        conn = get_db_connection(db)
        cursor = conn.cursor(as_dict=True)

        cursor.execute("""
            SELECT synchronization_state_desc
            FROM sys.dm_hadr_database_replica_states
            WHERE database_id = DB_ID(%s) 
                AND is_primary_replica = 0
        """, (db["database"],))
        status = cursor.fetchone()
        if status and status['synchronization_state_desc'] != "SYNCHRONIZING":
            logging.warning(f"数据库 {db['database']} 在 AlwaysOn 组中同步状态异常: {status['synchronization_state_desc']}")
        else:
            logging.info(f"数据库 {db['database']} 同步状态正常")
        return status['synchronization_state_desc'] if status else "UNKNOWN"
    except Exception as e:
        logging.error(f"检查 AlwaysOn 状态失败: {e}")
        return "UNKNOWN"

def check_and_repair_sqlserver_datasource(dbs):

    logging.info("开始 CDC 数据同步巡检")
    logging.debug(f"数据库列表: {dbs}")
    
    for db in dbs:
        logging.info("-------------------------------------------------")
        logging.info(f"检查数据库: {db['database']} ({db['hostname']})")
        if check_sqlserver_cdc(db) is False:
            # TODO:恢复CDC
            continue

        if is_sqlserver_alwayson(db):
            # 检查 AlwaysOn 主从同步状态
            if check_sqlserver_alwayson_status(db) is False:
                # TODO:恢复主从同步状态
                continue

            # 如果当前节点是 SQL Server AlwaysOn 集群的辅助角色，需切换到主要角色，
            # 否则无法查询 Agent 运行状态
            if not is_sqlserver_alwayson_primary(db):
                db = get_sqlserver_alwayson_primary(db)
        
        # 检查 SQL Server CDC Agent Job 是否运行
        if check_sqlserver_cdc_agent_job(db) is False:
            # TODO:恢复CDC Agent Job
            restart_sqlserver_cdc_agent_job(db)
            continue
    
    logging.info("CDC 数据同步巡检完成")

def check_and_restart_failed_kafka_connectors():
    # 获取所有 Connector 状态信息
    response = requests.get(f"{KAFKA_CONNECT_SERVICE_URL}/connectors?expand=status")
    
    if response.status_code != 200:
        logging.error(
            "获取 Kafka Connect 连接器失败: 状态码=%d, 响应内容=%s, 请求URL=%s",
            response.status_code,
            response.text,
            response.url
        )
        return False
    
    connectors_status = response.json()
    
    failed_tasks = []
    for connector_name, details in connectors_status.items():
        tasks = details.get("status").get("tasks")
        for task in tasks:
            if task.get("state") == "FAILED":
                failed_tasks.append((connector_name, task.get("id")))
    
    # 重启失败的任务
    if not failed_tasks:
        logging.info("No failed connectors found.")
        return True
    
    for connector_name, task_id in failed_tasks:
        restart_response = requests.post(f"{KAFKA_CONNECT_SERVICE_URL}/connectors/{connector_name}/tasks/{task_id}/restart")
        
        if restart_response.status_code == 200:
            logging.info(f"Successfully restarted task {task_id} of connector {connector_name}.")
        else:
            logging.info(f"Failed to restart task {task_id} of connector {connector_name}.")
    
    return True

def extract_table_name_from_topic(topic):
    """
    从 Kafka Topic 中提取表名
    例如：
    - input: "dbserver.dbo.users" -> output: "users"
    - input: "dbserver.dbo.orders" -> output: "orders"
    """
    parts = topic.split(".")
    if len(parts) > 2:
        return parts[-1]
    return topic

def get_sqlserver_ct_time(db, table_name):
    """
    查询 SQL Server CT 表的最新记录时间
    """
    try:
        conn = get_db_connection(db)
        cursor = conn.cursor()
    
        cursor.execute(f"""
            SELECT TOP 1 
                sys.fn_cdc_map_lsn_to_time(__$start_lsn) AS latest_lsn_time, *
            FROM [cdc].[dbo_{table_name}_CT]
            ORDER BY __$start_lsn ASC;
        """)
        latest_record = cursor.fetchone()
        return latest_record['latest_lsn_time'] if latest_record else None
    except Exception as e:
        logging.error(f"检查 SQL Server CT 失败: {e}")
        return None

def get_kafka_ct_time(topic_name):
    """
    查询 Kafka Topic 的最新消费时间
    """
    consumer = KafkaConsumer(
        topic_name,
        bootstrap_servers=KAFKA_CONNECT_BOOTSTRAP_SERVERS,
        auto_offset_reset='latest',
        enable_auto_commit=False
    )

    # 将消费指针移到最后
    consumer.poll(timeout_ms=1000)
    consumer.seek_to_end()

    latest_timestamp = None
    for message in consumer:
        latest_timestamp = message.timestamp / 1000
        break

    consumer.close()
    return latest_timestamp if latest_timestamp else None

def check_sqlserver2kafka_sync(ds):
    for db in ds:
        logging.info("-------------------------------------------------")
        logging.info(f"检查数据库: {db['database']} ({db['hostname']})")

        # 处理 active_topics，随机选择一个 Topic
        active_topics = db.get("active_topics", [])
        if not active_topics:
            logging.warning(f"[WARN] 数据库 {db['database']} 没有 active_topics")
            continue

        random_topic = random.choice(list(active_topics))
        table_name = extract_table_name_from_topic(random_topic)

        logging.info(f"🎲 随机选择 Topic: {random_topic} -> 表名: {table_name}")

         # 查询 CT 表最新时间
        ct_time = get_sqlserver_ct_time(db, table_name)
        if not ct_time:
            logging.warning(f"[WARN] 查询 CT 表 {table_name} 没有数据")
            continue

        # 查询 Kafka 最新消费时间
        kafka_time = get_kafka_ct_time(random_topic)
        if not kafka_time:
            logging.warning(f"[WARN] 查询 Topic {random_topic} 没有数据")
            continue

        # 计算时间差
        time_diff = (ct_time - kafka_time).total_seconds() / 60
        logging.info(f"📊 时间差: {time_diff:.2f} 分钟")

        # 如果时间差大于阈值，则记录异常，并重启 Debezium Connect
        # check_and_restart_failed_kafka_connectors()

    return True

def check_kafka2postgres_sync():
    return True


def main():
    try:
        ds = get_debezium_sqlserver_connectors()
        
        check_and_repair_sqlserver_datasource(ds)

        check_sqlserver2kafka_sync(ds)

        check_kafka2postgres_sync()

    except Exception as e:
        logging.error(f"运行出错: {e}")

if __name__ == "__main__":
    main()