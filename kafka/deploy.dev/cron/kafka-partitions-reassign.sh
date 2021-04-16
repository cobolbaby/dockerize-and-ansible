#!/bin/bash
cd `dirname $0`

if [ -z $1 ]; then
    echo 'No zookeeper service address specified ...'
    echo 'Usage: '$0' 192.168.2.16:2181'
    exit
fi

ZK_HOST=$1

unset KAFKA_OPTS JMX_PORT

topics=`cat ./topics-to-reassign.csv`

IFS=$'\n'
echo '{"version":1,"partitions":[' > topics-to-reassign.json
for i in $topics; do
    echo 'Handle Topic: "$i"'
    leaders=`kafka-topics --bootstrap-server localhost:9092 --describe --topic $i|grep Leader`
    for leader in $leaders; do
        partition=`echo $leader |awk '{print $4}'`
        leader=`echo $leader |awk '{print $6}'`
        # 如果需要保证 副分片 和 主分片 不在同一个 Broker 且随机分配在剩余的节点中，可以使用
        # follwer=`grep -vxF $leader ./leaders.csv | shuf -n2`
        follwer=`grep -vxF $leader ./leaders.csv`
        follwer1=`echo $follwer | awk '{print $1}'`
        follwer2=`echo $follwer | awk '{print $2}'`
        echo '{"topic":"'$i'","partition":'$partition',"replicas":['$leader','$follwer1','$follwer2']},' >> topics-to-reassign.json
    done
done
echo ']}' >> topics-to-reassign.json

# TODO:去除倒数第二行的结尾逗号
# kafka-reassign-partitions --zookeeper $ZK_HOST --execute --reassignment-json-file topics-to-reassign.json
# kafka-reassign-partitions --zookeeper $ZK_HOST --verify --reassignment-json-file topics-to-reassign.json
