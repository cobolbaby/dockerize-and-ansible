#!/bin/bash
set -e
cd `dirname $0`

BROKER_CLUSTER_IP=(10.191.7.11 10.191.7.13 10.191.7.14)
BROKER_CLUSTER_VERSION=5.5.11
ZOOKEEPER_CLUSTER=zoo1:2181
HARBOR_REGISTRY=registry.inventec

# Ref: https://stackoverflow.com/questions/8880603/loop-through-an-array-of-strings-in-bash
for i in "${!BROKER_CLUSTER_IP[@]}"
do
    # 设置环境变量，节点的IP
    export BROKER_NODE$((i+1))_IP=${BROKER_CLUSTER_IP[i]}
done

export BROKER_VERSION=${BROKER_CLUSTER_VERSION}
export REGISTRY=${HARBOR_REGISTRY}
export ZOOKEEPER=${ZOOKEEPER_CLUSTER}

echo "Harbor仓库地址: ${REGISTRY}"
echo "KAFKA集群IP为: ${BROKER_NODE1_IP}, ${BROKER_NODE2_IP}, ${BROKER_NODE3_IP}"
echo "KAFKA版本为: ${BROKER_VERSION}"
echo "ZOOKEEPER版本为: ${ZOOKEEPER}"

# Ref: https://stackoverflow.com/questions/45804955/zookeeper-refuses-kafka-connection-from-an-old-client
# 确保容器重新创建
# docker stack rm kafka
# docker stack rm zookeeper

docker stack deploy -c docker-compose-zookeeper.yml zookeeper
docker stack deploy -c docker-compose-kafka.yml kafka
