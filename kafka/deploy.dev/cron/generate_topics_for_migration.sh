#!/bin/bash
cd `dirname $0`

if [ -z $1 ]; then
    echo 'No zookeeper service address specified ...'
    echo 'Usage: '$0' 192.168.2.16:2181'
    exit
fi

ZK_HOST=$1

unset KAFKA_OPTS JMX_PORT

topics=`kafka-topics --zookeeper $ZK_HOST --list`

IFS=$'\n'
echo '{"version":1,"topics":[' > topic-migration.json
for i in $topics;do
    echo '{"topic":"'$i'"},' >> topic-migration.json
done
echo ']}' >> topic-migration.json

# TODO:手动去除最后一个逗号
# sed -i 's/,]/]/g' topic-migration.json
# kafka-reassign-partitions --zookeeper $ZK_HOST --generate --topics-to-move-json-file topic-migration.json --broker-list 0,1,2
# TODO:save the console output to topic-reassignment.json
# kafka-reassign-partitions --zookeeper $ZK_HOST --execute --reassignment-json-file topic-reassignment.json
# kafka-reassign-partitions --zookeeper $ZK_HOST --verify --reassignment-json-file topic-reassignment.json
