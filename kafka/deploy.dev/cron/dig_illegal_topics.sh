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

for i in $topics;do
    replicsNum=`kafka-topics --zookeeper $ZK_HOST --describe --topic $i|grep ReplicationFactor|awk '{print $3}'|awk -F: '{print $2}'`
    PartitionCount=`kafka-topics --zookeeper $ZK_HOST --describe --topic $i|grep PartitionCount|awk '{print $2}'|awk -F: '{print $2}'`
    echo 'topic: '$i''
    echo 'replics: '$replicsNum''
    echo 'partitions: '$PartitionCount''
    
    if [ $replicsNum -lt 3 ];then
        echo  $i >> topics-to-reassign.txt
    fi
    # if [ $PartitionCount -lt 3 ];then
    #     kafka-topics --zookeeper $ZK_HOST --alter --partitions 3 --topic $i
    # fi
done