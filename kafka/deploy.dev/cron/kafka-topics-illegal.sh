#!/bin/bash
cd `dirname $0`

unset KAFKA_OPTS JMX_PORT

topics=`kafka-topics --bootstrap-server localhost:9092 --list`

for i in $topics;do
    replicsNum=`kafka-topics --bootstrap-server localhost:9092 --describe --topic $i|grep ReplicationFactor|awk '{print $3}'|awk -F: '{print $2}'`
    PartitionCount=`kafka-topics --bootstrap-server localhost:9092 --describe --topic $i|grep PartitionCount|awk '{print $2}'|awk -F: '{print $2}'`
    echo 'topic: '$i''
    echo 'replics: '$replicsNum''
    echo 'partitions: '$PartitionCount''
    
    if [ $replicsNum -lt 3 ];then
        echo  $i >> topics-to-reassign.csv
    fi
    # if [ $PartitionCount -lt 3 ];then
    #     kafka-topics --bootstrap-server localhost:9092 --alter --partitions 3 --topic $i
    # fi
done