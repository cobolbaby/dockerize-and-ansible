#!/bin/bash

# 用于支持pgbackrest备份
sudo /usr/sbin/sshd

# 获取启动模式，采用Patroni Or Not

# 如果采用 Patroni 则执行 patroni + yaml

# 如果是启动单点，则参考 PG 原始镜像的写法
readonly PATRONI_ENABLE=${PATRONI_ENABLE:-false}

if [[ "$PATRONI_ENABLE" != "true" ]]; then
    echo "【`date`】Start a single instance..."
    docker-entrypoint.sh postgres
    exit
fi

echo "【`date`】Start Patroni..."

# Ref: https://www.cyberciti.biz/tips/bash-shell-parameter-substitution-2.html
# Remove Pattern (Back of $VAR)
PATRONI_NAMESPACE=${PATRONI_NAMESPACE:-/pgcluster}
DOCKER_HOSTNAME=$(hostname -I | cut -d' ' -f1)

export PATRONI_NAMESPACE=${PATRONI_NAMESPACE%/}
export PATRONI_SCOPE=${PATRONI_SCOPE:-pgcluster_dev_12}
export PATRONI_NAME="${PATRONI_NAME:-$(hostname)}"
export PATRONI_RESTAPI_LISTEN="0.0.0.0:8008"
export PATRONI_RESTAPI_CONNECT_ADDRESS="${PATRONI_RESTAPI_CONNECT_ADDRESS:-$DOCKER_HOSTNAME:8008}"
export PATRONI_POSTGRESQL_LISTEN="0.0.0.0:5432"
export PATRONI_POSTGRESQL_CONNECT_ADDRESS="${PATRONI_POSTGRESQL_CONNECT_ADDRESS:-$DOCKER_HOSTNAME:5432}"
export PATRONI_POSTGRESQL_DATA_DIR="${PATRONI_POSTGRESQL_DATA_DIR:-$PGDATA}"
export PATRONI_REPLICATION_USERNAME="${PATRONI_REPLICATION_USERNAME:-replicator}"
export PATRONI_REPLICATION_PASSWORD="${PATRONI_REPLICATION_PASSWORD:-1Password}"
export PATRONI_SUPERUSER_USERNAME="${PATRONI_SUPERUSER_USERNAME:-postgres}"
export PATRONI_SUPERUSER_PASSWORD="${PATRONI_SUPERUSER_PASSWORD:-1Password}"

PATRONI_TAGS_NOFAILOVER=${PATRONI_TAGS_NOFAILOVER:-false}

if [[ "$PATRONI_TAGS_NOFAILOVER" == "true" ]]; then
    sed -i 's/nofailover: false/nofailover: true/' /home/postgres/.config/patroni/patronictl.yaml
fi

readonly PATRONI_CLUSTER_MODE=${PATRONI_CLUSTER_MODE:-normal}

case $PATRONI_CLUSTER_MODE in
    "normal")
        exec patroni /home/postgres/.config/patroni/patronictl.yaml 2>&1
    ;;
    # "pgbackrest")
    #     # 如果配置为 pgbackrest，则需要校验 stanza 的配置是否存在，如果不存在，则需要创建？
    #     # 但貌似创建的时候需要数据库处于启动状态，所以没办法在集群没有创建的时候配置 stanza 
    #     exec patroni /home/postgres/.config/patroni/patronictl_pgbackrest.yaml 2>&1
    # ;;
    "restore")
        exec patroni /home/postgres/.config/patroni/patronictl_pgbackrest_restore.yaml 2>&1
    ;;
esac
