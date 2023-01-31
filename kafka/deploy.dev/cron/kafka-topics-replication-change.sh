#!/usr/bin/env bash

# Sample usage:
# ./bulk-topic-replication-change.sh node1:9091 zk1:2181 ~/ssl_command.config 1 2 3 4 5 6

unset KAFKA_OPTS JMX_PORT

broker="$1"
shift 1
zookeeper="$1"
shift 1
properties_file="$1"
shift 1
new_rf="$@"

if [ -z "$broker" ] | [ -z "$zookeeper" ] | [ -z "$properties_file" ] | [ -z "$new_rf" ]; then
    echo "Usage $0 <broker:port> <zookeeper:port> <absolute path to properties file> <replica broker ID list>"
    echo ""
    exit 1
fi

#FIXME: Regex pattern 'ReplicationFactor: [12345]' means I want to increase RF for any topics with replication factor of 1,2,3,4, or 5
topic_list=$(kafka-topics --bootstrap-server $broker --command-config $properties_file -describe | grep -E 'ReplicationFactor: [1]' | awk '{ print $2}')

LOG_FILE="bulk-change.log"
for t in $topic_list; do
    echo $t | tee -a $LOG_FILE
    bash ./increase-replication-factor.sh $broker $zookeeper $properties_file $t $new_rf  | tee -a $LOG_FILE
done
