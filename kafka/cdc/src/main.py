import json
import logging
import os
import random
import re
import sys
from configparser import ConfigParser
from datetime import datetime, timezone

import psycopg2
import pymssql
import requests
from confluent_kafka import (Consumer, ConsumerGroupTopicPartitions,
                             KafkaException, TopicPartition)
from confluent_kafka.admin import AdminClient

# 配置参数
KAFKA_CONNECT_SERVICE_URL = os.getenv("KAFKA_CONNECT_SERVICE_URL")
KAFKA_CONNECT_BOOTSTRAP_SERVERS = os.getenv("KAFKA_CONNECT_BOOTSTRAP_SERVERS", "")
REDPANDA_API = os.getenv("REDPANDA_API")

if KAFKA_CONNECT_SERVICE_URL is None or REDPANDA_API is None:
    print("KAFKA_CONNECT_SERVICE_URL/REDPANDA_API environment variable is not set.")
    sys.exit(1)  # 1 signifies an error, 0 would indicate success

# 默认 properties 文件路径
DEFAULT_PROPERTIES_FILE = "connect-credentials.properties"

# 设置日志
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')

# 数据库连接池
connections = {}

def get_sqlserver_connection(db):
    """获取或创建数据库连接（优先使用保留账号）"""
    db_key = (db["hostname"], db["port"], db["database"])

    if db_key not in connections:
        reserved_user = os.getenv("SQLSERVER_RESERVED_USER")
        reserved_password = os.getenv("SQLSERVER_RESERVED_PASSWORD")

        # 优先使用保留账号
        if reserved_user and reserved_password:
            try:
                connections[db_key] = pymssql.connect(
                    server=db["hostname"],
                    port=db["port"],
                    database=db["database"],
                    user=reserved_user,
                    password=reserved_password,
                    as_dict=True,
                    login_timeout=5
                )
                return connections[db_key]
            except Exception as e:
                logging.warning(f"使用保留账号连接失败: {e}，尝试使用原始账号。")

        # 保留账号不存在或失败，使用原始账号连接
        try:
            connections[db_key] = pymssql.connect(
                server=db["hostname"],
                port=db["port"],
                database=db["database"],
                user=db["user"],
                password=db["password"],
                as_dict=True,
                login_timeout=5  # Connection timeout set to 5 seconds
            )
        except Exception as e:
            logging.error(f"使用原始账号连接数据库失败: {e}")
            raise e

    return connections[db_key]

def get_postgres_connection(db):
    """获取或创建数据库连接"""
    db_key = (db["hostname"], db["port"], db["database"])

    if db_key not in connections:
        try:
            connections[db_key] = psycopg2.connect(
                host=db["hostname"],
                port=db["port"],
                dbname=db["database"],
                user=db["user"],
                password=db["password"],
                sslmode="disable"
            )
            connections[db_key].autocommit = True
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
        logging.error(f"读取 properties 文件失败: {e}")
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
    response = requests.get(f"{KAFKA_CONNECT_SERVICE_URL}/connectors?expand=info&expand=status")
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
    for connector, details in connectors.items():
        config = details.get("info").get("config")
        status = details.get("status").get("connector").get("state")
        driver = config.get("connector.class")
        
        # 判断是否为 Debezium SQL Server 连接器
        if driver == "io.debezium.connector.sqlserver.SqlServerConnector" or \
            driver == "io.debezium.connector.postgresql.PostgresConnector":
            
            config = {k: resolve_placeholders(v) for k, v in config.items()}
            # fix: 兼容 Debezium 2.x 版本的配置
            dbname = config.get("database.dbname") if config.get("database.dbname") else config.get("database.names")

            db_key = (dbname, config.get("database.hostname"), config.get("database.port", 1433))
            if db_key not in db_dict:
                db_dict[db_key] = {
                    "driver": driver,
                    "database": dbname,
                    "hostname": config.get("database.hostname"),
                    "port": config.get("database.port", 1433),
                    "user": config.get("database.user"),
                    "password": config.get("database.password"),
                    "tables": set(),
                    "topics": set(),
                    "active_topics": set(),
                    "connectors": set()
                }

            # 如果 Task 是 PAUSED 状态，则跳过
            if status == "PAUSED":
                logging.warning(f"连接器 {connector} 当前状态为 {status}，跳过")
                continue

            # 更新表集合
            db_dict[db_key]["tables"].update(config.get("table.include.list", "").split(","))

            topics = get_kafka_connect_all_topics(config)
            db_dict[db_key]["topics"].update(topics)

            active_topics = get_kafka_connect_active_topics(config)
            db_dict[db_key]["active_topics"].update(active_topics)

            db_dict[db_key]['connectors'].add(connector)

    return list(db_dict.values())

def get_kafka_connect_active_topics(connector_config):
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

# 获取 Active Connect 依赖的所有 Topic
def get_kafka_connect_all_topics(connector_config):
    topics = set()

    # 1. topic.prefix 本身对应一个 topic（Debezium 会记录 schema 变更）
    topic_prefix = connector_config.get("topic.prefix")
    if topic_prefix:
        topics.add(topic_prefix)

    # 2. schema.history.internal.kafka.topic
    schema_topic = connector_config.get("schema.history.internal.kafka.topic")
    if schema_topic:
        topics.add(schema_topic)

    # 3. 转换后的数据 topics（根据 table.include.list 和 topic 路由规则）
    table_include_list = connector_config.get("table.include.list", "")
    tables = [t.strip() for t in table_include_list.split(",") if t.strip()]

    # 默认逻辑为 topic.prefix + "." + table_name（如果没有 transform）
    transformed = connector_config.get("transforms", "") == "Reroute"
    if transformed:
        regex = connector_config.get("transforms.Reroute.topic.regex")
        replacement = connector_config.get("transforms.Reroute.topic.replacement")
        # Java -> Python regex replacement compatibility
        replacement_py = replacement.replace("$1", r"\1").replace("$2", r"\2")
        dbname = connector_config.get("database.names")
        if regex and replacement_py:
            # 模拟 Reroute 的正则替换逻辑
            for table in tables:
                raw_topic = f"{topic_prefix}.{dbname}.{table}"
                transformed_topic = re.sub(regex, replacement_py, raw_topic)
                topics.add(transformed_topic)
    else:
        logging.warning(f"未启用 transform，将使用默认格式拼接 Topic，请检查配置")
        
        # 如果没有启用 transform，按默认格式拼接
        for table in tables:
            topics.add(f"{topic_prefix}.{table}")

    return topics

def check_sqlserver_cdc(db):
    """检查 SQL Server 是否启用 CDC，并比对表"""
    try:
        conn = get_sqlserver_connection(db)
        cursor = conn.cursor()

        cursor.execute("SELECT is_cdc_enabled FROM sys.databases WHERE name = %s", (db["database"],))
        is_cdc_enabled = cursor.fetchone()
        if not is_cdc_enabled or is_cdc_enabled["is_cdc_enabled"] == 0:
            logging.warning(f"数据库 {db['database']} 未启用 CDC，请执行以下命令启用:")
            logging.info(f"""
            USE {db['database']};
            EXEC sys.sp_cdc_enable_db;
            """)
        
        cursor.execute("SELECT name FROM sys.tables WHERE is_tracked_by_cdc = 1")
        cdc_tables = {"dbo." + row['name'] for row in cursor.fetchall()}
        synced_tables = set(db["tables"])

        need_enable_table_cdc = synced_tables - cdc_tables
        need_disable_table_cdc = cdc_tables - synced_tables

        return True, need_enable_table_cdc, need_disable_table_cdc
    except Exception as e:
        logging.error(f"检查 SQL Server CDC 失败: {e}")
        return False, set(), set()

def check_sqlserver_cdc_agent_job(db):
    """检查 SQL Server CDC Agent Job 是否运行"""
    conn = get_sqlserver_connection(db)
    cursor = conn.cursor()

    try:
        cursor.execute("EXEC msdb.dbo.sp_help_jobactivity @job_name = %s", (f'cdc.{db["database"]}_capture',))
        job_status = cursor.fetchone()
        if job_status and job_status['start_execution_date'] is not None and job_status['stop_execution_date'] is None:
            logging.info(f"数据库 {db['database']} 的 CDC Agent Job {db['database']}_capture 正常运行")
            return True

        logging.error(f"CDC or LogReader Agent Job for {db['database']} 未运行，尝试重启")
        return False
    except Exception as e:
        # The specified @job_name ('cdc.FISAMS_capture') does not exist.DB-Lib error message 20018, severity 16:
        # General SQL Server error: Check messages from the SQL Server

        # The capture job cannot be used by Change Data Capture to extract changes from the log when transactional replication is also enabled on the same database. 
        # When Change Data Capture and transactional replication are both enabled on a database, use the logreader agent to extract the log changes.

        cursor.execute("SELECT CAST(DATABASEPROPERTYEX(%s, 'IsPublished') AS INT) AS IsPublished", (db["database"]))
        repl_status = cursor.fetchone()
        if repl_status and repl_status['IsPublished'] == 1:
            logging.info(f"数据库 {db['database']} 启用了 Replication，跳过检查 CDC Agent Job")
            logging.warning(f"数据库 {db['database']} 启用了 Replication，但要注意 LogReader Agent 是定时运行，时延较 CDC 有差异")
            return True

        logging.error(f"CDC or LogReader Agent Job for {db['database']} 均未运行: {e}")
        return False

def restart_sqlserver_cdc_agent_job(db):
    """重启 CDC Agent Job"""
    try:
        conn = get_sqlserver_connection(db)
        cursor = conn.cursor()

        cursor.execute("EXEC msdb.dbo.sp_start_job @job_name = %s", (f'cdc.{db["database"]}_capture'))
        logging.info(f"重启 CDC Agent Job {db['database']}_capture 成功")
    except Exception as e:
        logging.error(f"重启 CDC Agent Job {db['database']}_capture 失败: {e}")

def is_sqlserver_alwayson(db):
    """检查是否为 AlwaysOn 集群"""
    try:
        conn = get_sqlserver_connection(db)
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
        conn = get_sqlserver_connection(db)
        cursor = conn.cursor(as_dict=True)

        # 使用 sys.fn_hadr_is_primary_replica 判断当前实例是否为主节点
        # https://learn.microsoft.com/en-us/sql/relational-databases/system-functions/sys-fn-hadr-is-primary-replica-transact-sql?view=sql-server-ver16
        cursor.execute("""
            SELECT sys.fn_hadr_is_primary_replica(%s) AS is_primary
        """, (db["database"],))
        result = cursor.fetchone()

        if result and (result['is_primary'] == 1 or result['is_primary'] is None):
            logging.info(f"数据库 {db['database']} 所在 AlwaysOn 集群节点 {db['hostname']} 是主节点")
            return True
        else: # is_primary 为 0 则不是主节点
            logging.info(f"数据库 {db['database']} 所在 AlwaysOn 集群节点 {db['hostname']} 是辅助节点")
            return False
    except Exception as e:
        logging.error(f"检查 AlwaysOn 主节点状态失败: {e}")
        return False

def get_sqlserver_alwayson_primary(db):
    """获取 AlwaysOn 集群的主节点地址并更新数据库配置"""
    try:
        conn = get_sqlserver_connection(db)
        cursor = conn.cursor()
        
        # 
        cursor.execute("""
            SELECT primary_replica 
            FROM sys.dm_hadr_availability_group_states;
        """)
        result = cursor.fetchone()
        if result:
            logging.info(f"数据库 {db['database']} 所在 AlwaysOn 集群的主节点是 {result['primary_replica']}")
            # 修改数据库连接信息指向主节点
            db["hostname"] = result["primary_replica"]
        return db
    except Exception as e:
        logging.error(f"获取 AlwaysOn 主节点地址失败: {e}")
        return db

def check_sqlserver_alwayson_status(db):
    """检查 SQL Server AlwaysOn 状态"""
    try:
        conn = get_sqlserver_connection(db)
        cursor = conn.cursor(as_dict=True)

        # https://learn.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/sys-dm-hadr-database-replica-states-transact-sql?view=azuresqldb-current
        cursor.execute("""
            SELECT synchronization_state_desc
            FROM sys.dm_hadr_database_replica_states
            WHERE database_id = DB_ID(%s) 
                AND is_primary_replica = 0
        """, (db["database"],))
        status = cursor.fetchone()
        if status is None:
            logging.info(f"数据库 {db['database']} 不属于 AlwaysOn 高可用组")
            return True

        if status and status['synchronization_state_desc'] != "SYNCHRONIZING":
            logging.error(f"数据库 {db['database']} 属于 AlwaysOn 高可用组，但同步状态异常: {status['synchronization_state_desc']}")
            return False
        
        logging.info(f"数据库 {db['database']} 属于 AlwaysOn 高可用组，且同步状态正常")
        return True
    except Exception as e:
        logging.error(f"检查 AlwaysOn 状态失败: {e}")
        return False

def apply_sqlserver_cdc_changes(db, enable_tables, disable_tables, dry_run=True):
    """根据表名集合启用或禁用 SQL Server 的 CDC"""
    try:
        conn = get_sqlserver_connection(db)
        cursor = conn.cursor()

        # 启用 CDC
        for table in enable_tables:
            logging.warning(f"待启用表 {db['hostname']}.{db['database']}.{table} 的 CDC")

            table_name = table.split(".")[-1]
            sql = f"""
            USE {db['database']};
            EXEC sys.sp_cdc_enable_table
                @source_schema = N'dbo',
                @source_name   = N'{table_name}',
                @role_name     = NULL,
                @supports_net_changes = 1;
            """
            logging.info(sql)
            if not dry_run:
                try:
                    cursor.execute(sql)
                    conn.commit()
                    logging.info(f"已启用表 {table} 的 CDC")
                except Exception as e:
                    logging.error(f"启用表 {table} 的 CDC 失败: {e}")

        # 禁用 CDC
        for table in disable_tables:
            logging.warning(f"待关闭表 {db['hostname']}.{db['database']}.{table} 的 CDC")

            table_name = table.split(".")[-1]
            sql = f"""
            USE {db['database']};
            EXEC sys.sp_cdc_disable_table 
                @source_schema = N'dbo', 
                @source_name = N'{table_name}', 
                @capture_instance = N'dbo_{table_name}';
            """
            logging.info(sql)
            if not dry_run:
                try:
                    cursor.execute(sql)
                    conn.commit()
                    logging.info(f"已禁用表 {table} 的 CDC")
                except Exception as e:
                    logging.error(f"禁用表 {table} 的 CDC 失败: {e}")

    except Exception as e:
        logging.error(f"启用或禁用 SQL Server 的 CDC 失败: {e}")

def check_and_repair_sqlserver_datasource(dbs):

    for db in dbs:
        logging.info("-------------------------------------------------")
        logging.info(f"检查数据库: {db['database']} ({db['hostname']})")

        success, need_enable_table_cdc, need_disable_table_cdc = check_sqlserver_cdc(db)
        if success is False:
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
            restart_sqlserver_cdc_agent_job(db)
            # continue

        # 自动开启关闭 CDC，默认只打印待执行的操作，但如果 DRY RUN 关闭，则真正执行
        apply_sqlserver_cdc_changes(db, need_enable_table_cdc, need_disable_table_cdc, dry_run=True)


def get_kafka_connect_tasks_status(connector_name):
    """
    获取 Kafka Connect Job 的任务状态。
    """
    try:
        response = requests.get(f"{KAFKA_CONNECT_SERVICE_URL}/connectors/{connector_name}/status")

        if response.status_code != 200:
            logging.error(f"Failed to fetch status for {connector_name}: {response.text}")
            return None

        return response.json()
    except requests.RequestException as e:
        logging.error(f"Failed to connect to Kafka Connect API: {e}")
        return None

def restart_kafka_connect_tasks(connector_name, task_id):
    """
    重启指定 Kafka Connect 任务。
    """
    restart_response = requests.post(f"{KAFKA_CONNECT_SERVICE_URL}/connectors/{connector_name}/tasks/{task_id}/restart")

    if restart_response.status_code in [200, 204]:
        logging.info(f"Successfully restarted task {task_id} of connector {connector_name}.")
        return True
    else:
        logging.error(f"Failed to restart task {task_id} of connector {connector_name}. Response: {restart_response.text}")
        return False

def check_kafka_connect_failed_tasks(trace):
    """
    根据任务异常信息 (trace) 判断是否应该重启任务。
    例如，某些致命错误（如配置错误）不适合重启，而临时网络错误可以尝试重启。
    """
    if not trace:
        return True  # 没有错误信息，默认允许重启

    # 定义不可重启的错误关键字
    non_restartable_errors = [
        "configured with 'delete.enabled=false' and 'pk.mode=none' and therefore requires records with a non-null Struct value and non-null Struct schema", # 主键为空 -- 源头加主键
        "You will need to rewrite or cast the expression", # 字段类型问题 -- 最好源头修正
        "io.confluent.connect.jdbc.sink.TableAlterOrCreateException", # 上游新增字段，下游未同步增加 -- 下游跟进
    ]
    
    for error in non_restartable_errors:
        if error in trace:
            logging.warning(f"Skipping restart due to critical error: {error}")
            return False

def check_and_restart_kafka_connect_failed_tasks():
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
                failed_tasks.append((connector_name, task.get("id"), task.get("trace")))
    
    # 重启失败的任务
    if not failed_tasks:
        logging.info("No failed connectors found.")
        return True
    
    for connector_name, task_id, trace in failed_tasks:

        if not check_kafka_connect_failed_tasks(trace):
            logging.info(f"Skipping restart for {connector_name} - Task {task_id} due to non-restartable error.")
            continue

        restart_kafka_connect_tasks(connector_name, task_id)
    
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
    查询 SQL Server CT 表的最新记录时间，并动态转换为 UTC Unix 时间戳 (毫秒级)
    """
    try:
        conn = get_sqlserver_connection(db)  # 获取数据库连接
        cursor = conn.cursor()

        # 获取 SQL Server 当前时区偏移量
        cursor.execute("SELECT SYSDATETIMEOFFSET() as server_local_time")
        server_local_time = cursor.fetchone()['server_local_time']  # 返回带时区的 datetime 对象
        
        # 解析 SQL Server 的时区偏移量
        utcoffset = server_local_time.utcoffset()  # 获取时区偏移量 (timedelta)

        # 查询最新的 CDC 记录时间
        cursor.execute(f"""
            SELECT TOP 1 
                sys.fn_cdc_map_lsn_to_time(__$start_lsn) AS latest_lsn_time,
                *
            FROM [cdc].[dbo_{table_name}_CT]
            ORDER BY __$start_lsn DESC;
        """)

        latest_record = cursor.fetchone()
        
        if latest_record:
            latest_lsn_time = latest_record['latest_lsn_time']  # SQL Server 返回的本地时间 (without timezone)
            
            # 时间附加上时区信息 
            latest_lsn_time = latest_lsn_time.replace(tzinfo=timezone(utcoffset))  
            
            # 转换为 UTC
            lsn_utc_time = latest_lsn_time.astimezone(timezone.utc)
            
            # 转换为 Unix 时间戳 (毫秒级)
            return int(lsn_utc_time.timestamp() * 1000)  

        return None
    except Exception as e:
        logging.error(f"检查 SQL Server CT 失败: {e}")
        return None
# https://github.com/confluentinc/confluent-kafka-python/blob/master/examples/get_watermark_offsets.py
def get_kafka_ct_time(topic):
    """
    获取 Kafka Topic 各分区最新的一条消息，并返回最新的时间戳
    """
    try:
        consumer = Consumer({
            'bootstrap.servers': KAFKA_CONNECT_BOOTSTRAP_SERVERS,
            'group.id': 'monitoring-consumer',
            'auto.offset.reset': 'latest',
            'enable.auto.commit': False
        })

        # Get the topic's partitions
        metadata = consumer.list_topics(topic)
        if metadata.topics[topic].error is not None:
            raise KafkaException(metadata.topics[topic].error)

        # Construct TopicPartition list of partitions to query
        partitions = [TopicPartition(topic, p) for p in metadata.topics[topic].partitions.keys()]

        latest_timestamp = None

        for tp in partitions:
            # 获取分区的 offset
            low_offset, high_offset = consumer.get_watermark_offsets(tp, cached=False)
            if high_offset == 0 or high_offset == low_offset:
                continue  # 该分区没有数据，跳过

            # 重新创建 TopicPartition 对象，设置 offset
            tp_with_offset = TopicPartition(tp.topic, tp.partition, high_offset - 1)
            
            # fix: Error: KafkaError{code=_STATE,val=-172,str="Failed to seek to offset 7554142: Local: Erroneous state"}
            # consumer.seek(tp_with_offset)
            consumer.assign([tp_with_offset])

            msg = consumer.poll(timeout=5.0)  # 获取最新消息
            if msg and not msg.error():
                msg_ts = msg.timestamp()[1]
                if latest_timestamp is None or msg_ts > latest_timestamp:
                    latest_timestamp = msg_ts

        consumer.close()

        return latest_timestamp
    except Exception as e:
        logging.error(f"Error occurred while checking kafka_ct_time of topic {topic}: {e}")
        return None

def check_sqlserver2kafka_sync(ds, max_retries=3):
    for db in ds:
        logging.info("-------------------------------------------------")
        logging.info(f"检查数据库: {db['database']} ({db['hostname']})")

        # 处理 active_topics，随机选择一个 Topic
        active_topics = db.get("active_topics", [])
        if not active_topics:
            logging.warning(f"[WARN] 数据库 {db['database']} 没有 active_topics")
            continue

        attempts = 0
        while attempts < max_retries and active_topics:
            random_topic = random.choice(list(active_topics))
            table_name = extract_table_name_from_topic(random_topic)
            logging.info(f"🎲 随机选择 Topic: {random_topic} -> 表名: {table_name}")

            # 查询 CT 表最新时间
            ct_time = get_sqlserver_ct_time(db, table_name)
            if not ct_time:
                logging.warning(f"[WARN] 查询 CT 表 {table_name} 没有数据，移除 Topic [{random_topic}]，重试 {attempts+1}/{max_retries}")
                active_topics.remove(random_topic)  # 从列表中移除无数据的 Topic
                attempts += 1
                continue  # 重新选择一个 Topic 再试
            break  # 成功获取到 CT 时间，则退出重试循环

        if not ct_time:
            logging.error(f"[ERROR] 数据库 {db['database']} 里所有 Topic 都没有 CT 数据，跳过")
            continue

        # 查询 Kafka 最新消费时间
        kafka_time = get_kafka_ct_time(random_topic)
        if not kafka_time:
            logging.warning(f"[WARN] 查询 Topic {random_topic} 没有数据")
            continue

        # 计算时间差
        time_diff = (kafka_time - ct_time) / 1000
        logging.info(f"📊 时间差: {time_diff:.3f} 秒")

        if time_diff > 60:
            logging.warning(f"[WARN] 时间差超过阈值: {time_diff:.3f} 秒")
            # TODO:尝试重启 Debezium Connect

        else:
            logging.info(f"✅ 时间差在阈值范围内: {time_diff:.3f} 秒")

    return True

# 检测 CDC Topic 是否有 Lag
def check_kafka2postgres_sync():
    high_lag_groups = get_kafka_lag_consumer_groups_v2()

    if not high_lag_groups:
        logging.info("No high lag consumer groups found.")
        return True

    # 生成 Kafka Connect Job 名称并重启
    for group_id in high_lag_groups:
        # 去掉 `connect-` 前缀，就是 JDBC Connect Job 名称
        connector_name = group_id.replace("connect-", "", 1)
        
        tasks_status = get_kafka_connect_tasks_status(connector_name)
        if tasks_status is None:
            logging.error(f"Skipping restart: Failed to retrieve status for {connector_name}.")
            continue

        tasks = tasks_status.get("tasks", [])
        restart_needed = False

        for task in tasks:
            task_id = task.get("id")
            task_state = task.get("state")
            trace = task.get("trace", "")

            if task_state == "FAILED":
                if check_kafka_connect_failed_tasks(trace):
                    logging.warning(f"Task {task_id} of {connector_name} is FAILED. Restarting ...")
                    restart_needed = True
                else:
                    logging.warning(f"Skipping restart for {connector_name} - Task {task_id} due to non-restartable error.")
            
            elif task_state in ["RUNNING", "UNASSIGNED"]:
                logging.info(f"Task {task_id} of {connector_name} is {task_state}. Restarting due to high lag ...")
                restart_needed = True

            # 执行重启
            if restart_needed:
                restart_kafka_connect_tasks(connector_name, task_id)

    return True

def get_kafka_lag_consumer_groups():
    """
    获取 Kafka 所有 consumer group 的 lag 信息（优化为批量查询）
    """
    try:
        admin_client = AdminClient({
            'bootstrap.servers': KAFKA_CONNECT_BOOTSTRAP_SERVERS
        })
        
        consumer = Consumer({
            'bootstrap.servers': KAFKA_CONNECT_BOOTSTRAP_SERVERS,
            'group.id': 'monitoring-consumer',
            'auto.offset.reset': 'latest',
            'enable.auto.commit': False
        })

        # 获取所有 consumer group
        future_groups = admin_client.list_consumer_groups(request_timeout=10)
        groups = future_groups.result()
        
        consumer_group_ids = [ConsumerGroupTopicPartitions(g.group_id) for g in groups.valid 
                              if g.group_id.startswith("connect-")]
        if not consumer_group_ids:
            logging.warning("No consumer groups match the filter.")
            return []
        
        logging.info(f"Fetching offsets for {len(consumer_group_ids)} consumer groups...")

        high_lag_groups = []

        # TODO:由于 lib 库不支持批量查询的操作，所以只能循环处理
        for consumer_group_id in consumer_group_ids:

            # 批量请求 consumer group 的 offsets
            future_offsets = admin_client.list_consumer_group_offsets([consumer_group_id])

            group_id = consumer_group_id.group_id
            offsets = future_offsets[group_id].result()
            
            logging.debug(f"Consumer Group: {group_id}")
            summedLag = 0
            for tp in offsets.topic_partitions:
                # 获取 partition 最新 offset（high watermark）
                high_watermark = consumer.get_watermark_offsets(tp)[1]  # (low, high)
                lag = high_watermark - tp.offset  # 计算 lag
                summedLag += lag
                logging.debug(f"  Topic: {tp.topic}, Partition: {tp.partition}, Lag: {lag}")

            # 过滤出 lag > 100
            if summedLag > 200:
                logging.info(f"High lag consumer group: {group_id}, Summed Lag: {summedLag}")
                high_lag_groups.append(group_id)
            
        return high_lag_groups
    except Exception as e:
        logging.error(f"Error fetching consumer groups: {e}")
        return []

# 通过 RedPanda API 获取 Consumer Groups
def get_kafka_lag_consumer_groups_v2():
    response = requests.get(f"{REDPANDA_API}/api/consumer-groups")
    if response.status_code != 200:
        logging.error("Failed to fetch consumer groups")
        return []

    data = response.json()

    # 过滤出 lag > 100
    high_lag_groups = []
    for group in data.get("consumerGroups", []):
        if group["groupId"].startswith("connect-") is False:
            continue

        for topic in group.get("topicOffsets", []):
            if topic["summedLag"] > 200:
                logging.info(f"High lag consumer group: {group['groupId']}, Summed Lag: {topic['summedLag']}")
                high_lag_groups.append(group["groupId"])
                break  # 只要有一个 topic lag 超过 1000，就标记该 group 需要重启
    
    return high_lag_groups


def check_sqlserver2postgres_sync(ds, method="KAFKA"):

    if method.upper() == "KAFKA":
        check_sqlserver2kafka_sync(ds)

        check_and_restart_kafka_connect_failed_tasks()

        check_kafka2postgres_sync()
    elif method.upper() == "SEATUNNEL":
        check_sqlserver2postgres_sync_v2(ds)
    else:
        logging.error("不支持的 method")
        return

def check_sqlserver2postgres_sync_v2(ds):
    # TODO:待实现，需要结合血缘，获取源端 + 目标端的连接信息
    return 


def check_postgres_replication_slot(db):
    try:
        conn = get_postgres_connection(db)
        cursor = conn.cursor()
        cursor.execute("SELECT active FROM pg_replication_slots WHERE slot_name = %s", (db["replication_slot"],))
        result = cursor.fetchone()
        cursor.close()
        if result and result[0] is True:
            logging.info(f"数据库 {db['database']} replication slot {db['replication_slot']} 运行正常")
            return True
        else:
            logging.error(f"数据库 {db['database']} replication slot {db['replication_slot']} 运行异常")
            return False
    except Exception as e:
        logging.error(f"检查数据库 {db['database']} replication slot {db['replication_slot']} 运行状态失败: {e}")
        return False

def should_drop_postgres_replication_slot(trace):
    non_recoverable_keywords = [
        "ERROR: unexpected duplicate for tablespace 0, relfilenode", # 根因是个谜，但只要遇到就得重建
    ]
    return any(keyword in trace for keyword in non_recoverable_keywords)

def drop_postgres_replication_slot(db):
    try:
        conn = get_postgres_connection(db)
        cursor = conn.cursor()
        cursor.execute("SELECT pg_drop_replication_slot(%s)", (db['replication_slot'],))
        logging.warning(f"已删除 replication slot: {db['replication_slot']}")
        cursor.close()
    except Exception as e:
        logging.error(f"删除 replication slot {db['replication_slot']} 失败: {e}")

def check_and_repair_postgres_datasource(dbs):

    for db in dbs:
        # 如果 replication slot 未设置，则默认为 'debezium'
        if not db.get('replication_slot'):
            db['replication_slot'] = 'debezium'

        logging.info("-------------------------------------------------")
        logging.info(f"检查数据库: {db['database']} ({db['hostname']})")
        
        if check_postgres_replication_slot(db):
            continue

        logging.warning(f"尝试恢复 connector: {db['connectors']}")

        for connector in db['connectors']:
            tasks_status = get_kafka_connect_tasks_status(connector)
            if tasks_status is None:
                continue

            tasks = tasks_status.get("tasks", [])
            restart_needed = False
            recreate_needed = False

            for task in tasks:
                task_id = task.get("id")
                task_state = task.get("state")
                trace = task.get("trace", "")

                if task_state == "FAILED":
                    # 失败的任务要么重启能恢复，要么重启恢复不了，只能重建
                    if should_drop_postgres_replication_slot(trace):
                        logging.warning(f"Skipping restart for {connector} - Task {task_id} due to non-restartable error.")
                        recreate_needed = True
                    else:
                        logging.warning(f"Task {task_id} of {connector} is FAILED. Restarting ...")
                        restart_needed = True
                
                elif task_state in ["RUNNING", "UNASSIGNED"]:
                    # 先重启一把瞅瞅
                    logging.info(f"Task {task_id} of {connector} is {task_state}, but replication slot is inactive. Restarting task to recover.")
                    restart_needed = True

                if recreate_needed:
                    drop_postgres_replication_slot(db)

                if restart_needed:
                    restart_kafka_connect_tasks(connector, task_id)

def check_postgres2kafka_sync(ds):
    return

def get_kafka_topics():
    # TODO:Kafka Native API
    return []

def get_kafka_topics_v2():
    try:
        response = requests.get(f"{REDPANDA_API}/api/topics")
        response.raise_for_status()
        data = response.json()
        return {topic['topicName'] for topic in data.get('topics', [])}
    except requests.RequestException as e:
        logging.error(f"获取 Kafka Topic 列表失败: {e}")
        return set()

def check_and_repair_kafka_topics(dbs):
    all_topics = get_kafka_topics_v2()
    if not all_topics:
        logging.error("未能获取 Kafka Topic 列表，终止检查。")
        return

    for db in dbs:
        logging.info("-------------------------------------------------")
        logging.info(f"检查数据库: {db['database']} ({db['hostname']})")

        expected_topics = set(db.get('topics', []))               # B
        active_topics = set(db.get('active_topics', []))          # C
        # 前缀匹配的判断条件（带 . 的）
        prefixes = {t.rsplit('.', 1)[0] + '.' for t in expected_topics if '.' in t}
        # 等值匹配的判断条件（不带 . 的）
        exact_matches = {t for t in expected_topics if '.' not in t}
        # 匹配逻辑：
        matching_topics = {                                      # A
            t for t in all_topics
            if any(t.startswith(prefix) for prefix in prefixes) or t in exact_matches
        }

        # 差集分析
        deprecated_topics = matching_topics - expected_topics  # A - B
        missing_topics = expected_topics - matching_topics     # B - A
        inactive_topics = expected_topics - active_topics      # B - C

        # 输出废弃 Topic
        if deprecated_topics:
            logging.warning(f"发现废弃的 Topic（A - B）: {deprecated_topics}")
        else:
            logging.info("无废弃的 Topic（A - B）")

        # 输出缺失 Topic
        if missing_topics:
            logging.error(f"缺失的 Topic，需要创建（B - A）: {missing_topics}")
        else:
            logging.info("无缺失的 Topic（B - A）")

        # 活跃度检查
        if expected_topics:
            active_ratio = (len(expected_topics) - len(inactive_topics)) / len(expected_topics)
            logging.info(f"当前活跃 Topic 数量: {len(expected_topics) - len(inactive_topics)} / {len(expected_topics)}（活跃度: {active_ratio:.2%}）")
        else:
            logging.warning("未定义期望 Topic 集合（B），无法评估活跃度。")

    return

def main():
    try:
        ds = get_debezium_sqlserver_connectors()

        sqlds = [d for d in ds if d.get("driver") == "io.debezium.connector.sqlserver.SqlServerConnector"]

        logging.info("-------------------------------------------------")
        logging.info("SQL Server CDC 巡检开始")

        check_and_repair_sqlserver_datasource(sqlds)

        logging.info("-------------------------------------------------")
        logging.info("SQL Server CDC 巡检完成")

        logging.info("-------------------------------------------------")
        logging.info("Kafka Topics 巡检开始")

        check_and_repair_kafka_topics(sqlds)

        logging.info("-------------------------------------------------")
        logging.info("Kafka Topics 巡检完成")

        logging.info("-------------------------------------------------")
        logging.info("SQL Server2Postgres CDC 同步巡检开始")

        check_sqlserver2postgres_sync(sqlds, "KAFKA")

        logging.info("-------------------------------------------------")
        logging.info("SQL Server2Postgres CDC 同步巡检完成")

        pgds = [d for d in ds if d.get("driver") == "io.debezium.connector.postgresql.PostgresConnector"]
        
        logging.info("-------------------------------------------------")
        logging.info("PostgreSQL CDC 巡检开始")

        check_and_repair_postgres_datasource(pgds)

        logging.info("-------------------------------------------------")
        logging.info("PostgreSQL CDC 巡检完成")

        check_postgres2kafka_sync(pgds)

    except Exception as e:
        logging.error(f"运行出错: {e}")

if __name__ == "__main__":
    main()