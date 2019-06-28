#!/bin/bash
set -e
cd `dirname $0`

BROKER_CLUSTER_IP=(10.191.5.218 10.191.5.233 10.191.4.54)
BROKER_CLUSTER_VERSION=5.0.3
ZOOKEEPER_CLUSTER_IP=(10.191.5.218 10.191.5.233 10.191.4.54)
HARBOR_REGISTRY=harbor.inventec.com

# Ref: https://stackoverflow.com/questions/8880603/loop-through-an-array-of-strings-in-bash
for i in "${!BROKER_CLUSTER_IP[@]}"
do
    # 设置环境变量，节点的IP
    export BROKER_NODE$((i+1))_IP=${BROKER_CLUSTER_IP[i]}
done

export BROKER_VERSION=${BROKER_CLUSTER_VERSION}
export REGISTRY=${HARBOR_REGISTRY}

echo "Harbor仓库地址: ${REGISTRY}"
echo "KAFKA集群IP为: $BROKER_NODE1_IP, $BROKER_NODE2_IP, $BROKER_NODE3_IP"
echo "KAFKA版本为: $BROKER_VERSION"

# Ref: https://stackoverflow.com/questions/45804955/zookeeper-refuses-kafka-connection-from-an-old-client
# 确保容器重新创建
# docker stack rm kafka
# docker stack rm zookeeper

docker stack deploy -c docker-compose-kafka.yml kafka
# docker stack deploy -c docker-compose-zookeeper.yml zookeeper
