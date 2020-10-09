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
#     sort

# Restart any connector tasks that are FAILED
# curl -sS "${KAFKA_CONNECT_SERVICE_URI}/connectors" | \
#     jq '.[]' | \
#     xargs -I{connector_name} curl -sS "${KAFKA_CONNECT_SERVICE_URI}/connectors/"{connector_name}"/status" | \
#     jq -c -M '{name: .name, task: .tasks[]} | select(.task.state=="FAILED") | [.name, .task.id|tostring] | join("/tasks/")' | \
#     tr -d "\"" | \
#     xargs -I{connector_and_task} curl -v -X POST "${KAFKA_CONNECT_SERVICE_URI}/connectors/"{connector_and_task}"/restart"

# List current connectors and status
curl -sS "${KAFKA_CONNECT_SERVICE_URI}/connectors?expand=info&expand=status" | \
	jq '. | to_entries[] | [ .value.info.type, .key, .value.status.connector.state, .value.status.tasks[].state, .value.info.config."connector.class"] | join(":|:")' | \
	column -s : -t| sed 's/\"//g'| sort

# Restart any connector tasks that are FAILED
# Works for Apache Kafka >= 2.3.0 
# Thanks to @jocelyndrean for this enhanced code snippet that also supports 
# multiple tasks in a connector
curl -sS "${KAFKA_CONNECT_SERVICE_URI}/connectors?expand=status" | \
	jq -c -M 'map({name: .status.name} + {tasks: .status.tasks}) | .[] | {task: ((.tasks[]) + {name: .name})}  | select(.task.state=="FAILED") | {name: .task.name, task_id: .task.id|tostring} | ("/connectors/"+ .name + "/tasks/" + .task_id + "/restart")' | \
	xargs -I{connector_and_task} curl -v -X POST "${KAFKA_CONNECT_SERVICE_URI}"{connector_and_task}
