#!/bin/bash

# 获取启动模式，采用Patroni Or Not

# 如果采用 Patroni 则执行 patroni + yaml

# 如果是启动单点，则参考 PG 原始镜像的写法
readonly PATRONI_ENABLE=${PATRONI_ENABLE:-false}

if [ "$PATRONI_ENABLE" != "true" ]
then
    echo "【`date`】Start a single instance..."
    /docker-entrypoint.sh postgres
    exit
fi

echo "【`date`】Start Patroni..."

readonly PATRONI_SCOPE=${PATRONI_SCOPE:-patroni}
PATRONI_NAMESPACE=${PATRONI_NAMESPACE:-/pgcluster}
# Ref: https://www.cyberciti.biz/tips/bash-shell-parameter-substitution-2.html
# Remove Pattern (Back of $VAR)
readonly PATRONI_NAMESPACE=${PATRONI_NAMESPACE%/}
readonly DOCKER_IP=$(hostname --ip-address)

export PATRONI_NAMESPACE
export PATRONI_SCOPE
export PATRONI_NAME="${PATRONI_NAME:-$(hostname)}"
export PATRONI_RESTAPI_LISTEN="0.0.0.0:8008"
export PATRONI_RESTAPI_CONNECT_ADDRESS="$DOCKER_IP:8008"
export PATRONI_POSTGRESQL_LISTEN="0.0.0.0:5432"
export PATRONI_POSTGRESQL_CONNECT_ADDRESS="$DOCKER_IP:5432"
export PATRONI_POSTGRESQL_DATA_DIR="${PATRONI_POSTGRESQL_DATA_DIR:-$PGDATA}"
export PATRONI_REPLICATION_USERNAME="${PATRONI_REPLICATION_USERNAME:-replicator}"
export PATRONI_REPLICATION_PASSWORD="${PATRONI_REPLICATION_PASSWORD:-replicate}"
export PATRONI_SUPERUSER_USERNAME="${PATRONI_SUPERUSER_USERNAME:-admin123}"
export PATRONI_SUPERUSER_PASSWORD="${PATRONI_SUPERUSER_PASSWORD:-admin123}"

exec patroni /home/postgres/.config/patroni/patronictl.yaml
