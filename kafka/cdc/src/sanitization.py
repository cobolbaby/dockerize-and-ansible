import json
import logging
import os

import requests

logging.basicConfig(level=logging.INFO)
log = logging.getLogger(__name__)

KAFKA_CONNECT_URL = os.getenv("KAFKA_CONNECT_SERVICE_URL")  # 替换为实际地址
# 默认 properties 文件路径
DEFAULT_PROPERTIES_FILE = "connect-credentials.properties"

def parse_credentials(file_path):
    """ 解析 connect-credentials.properties 并生成映射字典 """
    mapping = {}
    with open(file_path, "r") as file:
        for line in file:
            line = line.strip()
            if not line or line.startswith("#"):  # 忽略空行和注释s
                continue
            key, value = map(str.strip, line.split("=", 1))
            prefix, field = key.rsplit("_", 1)  # 拆分 HOSTNAME, PORT, USER, PASSWORD
            
            if field in {"HOSTNAME", "PORT", "USER", "PASSWORD"}:
                if prefix not in mapping:
                    mapping[prefix] = {}
                mapping[prefix][field] = key  # 直接赋值，避免 `setdefault().update()`

            # 复制引用
            if field == "HOSTNAME":
                mapping[value] = mapping[prefix]

    log.info(f"Parsed credentials mapping: {json.dumps(mapping, indent=2)}")
    return mapping

def replace_config(config, mapping):
    """ 替换 Debezium 配置中的数据库连接信息 """
    hostname_key = config.get("database.hostname")

    # 如果 database.hostname 已经脱敏，则不替换
    if hostname_key \
        and hostname_key.startswith(f"${{file:/etc/kafka-connect/secrets/connect-credentials.properties"):
        return config, False

    if hostname_key in mapping:
        entry = mapping[hostname_key]
        config["database.hostname"] = f"${{file:/etc/kafka-connect/secrets/connect-credentials.properties:{entry['HOSTNAME']}}}"
        config["database.port"] = f"${{file:/etc/kafka-connect/secrets/connect-credentials.properties:{entry['PORT']}}}"
        config["database.user"] = f"${{file:/etc/kafka-connect/secrets/connect-credentials.properties:{entry['USER']}}}"
        config["database.password"] = f"${{file:/etc/kafka-connect/secrets/connect-credentials.properties:{entry['PASSWORD']}}}"
        return config, True  # 需要更新

    log.warning(f"No mapping found for hostname: {hostname_key}")
    return config, False  # 没有匹配，不需要更新

def fetch_connectors():
    """ 从 Kafka Connect 获取所有 connectors """
    url = f"{KAFKA_CONNECT_URL}/connectors?expand=info&expand=status"
    response = requests.get(url)
    response.raise_for_status()
    return response.json()

def update_connector(name, new_config):
    """ 更新 Kafka Connect 中的 connector 配置 """
    url = f"{KAFKA_CONNECT_URL}/connectors/{name}/config"
    headers = {"Content-Type": "application/json"}
    response = requests.put(url, headers=headers, data=json.dumps(new_config))
    if response.status_code >= 400:
        log.error(f"Failed to update connector {name}: {response.text}")
        return
    log.info(f"Updated connector: {name}")

def process_connectors(mapping):
    """ 处理 Kafka Connect 的 connectors，检查是否需要更新，跳过 PAUSED 状态的 Connector """
    try:
        connectors = fetch_connectors()
        for name, data in connectors.items():
            status = data["status"]["connector"]["state"]  # 获取 Connector 状态
            if status == "PAUSED":
                log.info(f"Skipping paused connector: {name}")
                continue  # 跳过暂停的 Connector
            
            config = data["info"]["config"]
            if "database.hostname" in config:
                new_config, updated = replace_config(config, mapping)
                if updated:
                    update_connector(name, new_config)
    except Exception as e:
        log.error(f"Error processing connectors: {e}")

if __name__ == "__main__":
    mapping = parse_credentials(DEFAULT_PROPERTIES_FILE)
    process_connectors(mapping)
