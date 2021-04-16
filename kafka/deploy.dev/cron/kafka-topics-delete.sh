#!/bin/bash
cd `dirname $0`

unset KAFKA_OPTS JMX_PORT

for t in `cat ./topics_del.csv`
do
    echo "[`date`]DELETE TOPIC: $t"
    # kafka-topics --bootstrap-server localhost:9092 --delete --topic $t
done
