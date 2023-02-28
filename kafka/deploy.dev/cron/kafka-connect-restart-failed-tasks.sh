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

# List current connectors and status
# curl -sS "${KAFKA_CONNECT_SERVICE_URI}/connectors" | \
# 	jq '.[]' | \
# 	xargs -I{connector_name} curl -sS "${KAFKA_CONNECT_SERVICE_URI}/connectors/"{connector_name}"/status" | \
# 	jq -c -M '[.name, .connector.state, .tasks[].state] | join(":|:")' | \
# 	column -s : -t | \
# 	tr -d "\"" | \
# 	sort

# Restart any connector tasks that are FAILED
# curl -sS "${KAFKA_CONNECT_SERVICE_URI}/connectors" | \
#     jq '.[]' | \
#     xargs -I{connector_name} curl -sS "${KAFKA_CONNECT_SERVICE_URI}/connectors/"{connector_name}"/status" | \
#     jq -c -M '{name: .name, task: .tasks[]} | select(.task.state=="FAILED") | [.name, .task.id|tostring] | join("/tasks/")' | \
#     tr -d "\"" | \
#     xargs -I{connector_and_task} curl -v -X POST "${KAFKA_CONNECT_SERVICE_URI}/connectors/"{connector_and_task}"/restart"

# List current connectors and status
curl -sS "${KAFKA_CONNECT_SERVICE_URI}/connectors?expand=status&expand=info" | \
	jq '.[] | [.status.type, .status.name, .status.connector.state, .status.tasks[].state] | join(":|:")' | \
	tr -d "\"" | sort | \
	column -s ":" -t

# Restart any connector tasks that are FAILED
# Works for Apache Kafka >= 2.3.0 
curl -sS "${KAFKA_CONNECT_SERVICE_URI}/connectors?expand=status" | \
	jq '.[] | {name: .status.name, task: .status.tasks[]} | select(.task.state=="FAILED") | [.name, .task.id|tostring] | join("/tasks/")' | \
	tr -d "\"" | \
	xargs -I{connector_and_task} curl -v -X POST "${KAFKA_CONNECT_SERVICE_URI}/connectors/"{connector_and_task}"/restart" 
	# xargs -I{connector_and_task} echo "${KAFKA_CONNECT_SERVICE_URI}/connectors/"{connector_and_task}"/restart" 
