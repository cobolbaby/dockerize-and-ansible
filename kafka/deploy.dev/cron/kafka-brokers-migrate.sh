#!/bin/bash
cd `dirname $0`

if [ -z $1 ]; then
    echo 'No zookeeper service address specified ...'
    echo 'Usage: '$0' 192.168.2.16:2181'
    exit
fi

ZK_HOST=$1

unset KAFKA_OPTS JMX_PORT

topics=`kafka-topics --bootstrap-server localhost:9092 --list`

TOPICJSON='{"version":1,"topics":['
for topic in $topics
do
    TOPICJSON+='{"topic":"'${topic}'"},'
done
TOPICJSON=${TOPICJSON:0:-1}
TOPICJSON+=']}'

echo $TOPICJSON | python -c 'import json, sys; f = open("topics-to-migrate.json", "w"); json.dump(json.load(sys.stdin), f, indent=4); f.close();'
# 生成执行迁移计划
kafka-reassign-partitions --zookeeper $ZK_HOST --generate --topics-to-move-json-file topics-to-migrate.json --broker-list 1,3,4 > topics-to-reassign.json.bak
# 仅保留最后一行
cat topics-to-reassign.json.bak | awk 'END {print}' > topics-to-reassign.json
# 开始执行
# kafka-reassign-partitions --zookeeper $ZK_HOST --execute --reassignment-json-file topics-to-reassign.json
# 验证过程
# kafka-reassign-partitions --zookeeper $ZK_HOST --verify --reassignment-json-file topics-to-reassign.json | grep -v successfully | wc -l
