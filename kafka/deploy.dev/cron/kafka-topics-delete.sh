#!/bin/bash
cd `dirname $0`

if [ -z $1 ]; then
    echo 'No zookeeper service address specified ...'
    echo 'Usage: '$0' 192.168.2.16:2181'
    exit
fi

ZK_HOST=$1

unset KAFKA_OPTS JMX_PORT

for t in $(kafka-topics --list --bootstrap-server localhost:19092 | grep -E '^CDC-(\w+)-(\w+)-(\w+)\.dbo\.(\w+)$')
do echo "[`date`]DELETE TOPIC: $t"; kafka-topics --zookeeper $ZK_HOST --delete --topic $t; done
