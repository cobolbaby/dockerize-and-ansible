#!/bin/bash
cd `dirname $0`

if [ -z $1 ]; then
    echo 'No zookeeper service address specified ...'
    echo 'Usage: '$0' 192.168.2.16:2181'
    exit
fi

ZK_HOST=$1

unset KAFKA_OPTS JMX_PORT

# 减少不必要的查询
topics=$(kafka-topics --zookeeper $ZK_HOST --describe | grep -E 'ReplicationFactor: 1' | awk '{ print $2}')
# or topics=$(kafka-topics --bootstrap-server localhost:9093 --command-config /kafka/tools/tools.properties --describe)

for t in $topics; do
    replicsNum=`kafka-topics --zookeeper $ZK_HOST --describe --topic $t|grep ReplicationFactor|awk '{print $6}'`

    partitionCount=`kafka-topics --zookeeper $ZK_HOST --describe --topic $t|grep PartitionCount|awk '{print $4}'`

    if [ "${replicsNum}" -lt 2 ]; then
        echo "Topic: ${t} Replics: ${replicsNum} Partitions: ${partitionCount}"
    fi
    
    # if [ $PartitionCount -lt 3 ]; then
    #     kafka-topics --zookeeper $ZK_HOST --alter --partitions 3 --topic $t
    # fi
done