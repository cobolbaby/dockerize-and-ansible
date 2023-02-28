#!/bin/bash
set -e
cd `dirname $0`

if [ -z $1 ]; then
    echo 'No kafka connect service address specified ...'
    echo 'Usage: '$0' http://10.191.6.53:8083'
    exit
fi

# What time is it Mr Wolf?
date

KAFKA_CONNECT_SERVICE_URI=$1

# Change Log Levels - Use the Connect API
# https://docs.confluent.io/platform/current/connect/logging.html#check-log-levels

curl -sS -v "${KAFKA_CONNECT_SERVICE_URI}/admin/loggers" | jq .

curl -sS -v "${KAFKA_CONNECT_SERVICE_URI}/admin/loggers/io.debezium.connector.sqlserver.SqlServerStreamingChangeEventSource" | jq .

curl -sS -v -X PUT -H "Content-Type: application/json" \
"${KAFKA_CONNECT_SERVICE_URI}/admin/loggers/io.debezium.connector.sqlserver.SqlServerStreamingChangeEventSource" \
-d '{"level": "DEBUG"}' | jq '.' 

sleep 10

curl -sS -v -X PUT -H "Content-Type: application/json" \
"${KAFKA_CONNECT_SERVICE_URI}/admin/loggers/io.debezium.connector.sqlserver.SqlServerStreamingChangeEventSource" \
-d '{"level": "ERROR"}' | jq '.' 


# ./kafka-connect-change-log-level.sh http://10.13.4.123:8083
# ./kafka-connect-change-log-level.sh http://10.13.52.28:8083
# ./kafka-connect-change-log-level.sh http://10.99.169.119:8083
# ./kafka-connect-change-log-level.sh http://10.45.35.33:8083