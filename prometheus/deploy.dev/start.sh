#!/bin/bash
set -e
cd `dirname $0`

export BROKER1_ADDR=${IP1}:9092 BROKER2_ADDR=${IP2}:9092 BROKER3_ADDR=${IP3}:9092
export PG_URI=postgresql://${USERNAME1}:${PASSWORD1}@${IP4}:5493/postgres?sslmode=disable
export ES_URI=http://${IP5}:9200
export MYSQL_URI="${USERNAME2}:${PASSWORD2}@(${IP6}:3306)/"
export MONGODB_URI=mongodb://${USERNAME3}:${PASSWORD3}@${IP7}:28028

docker stack deploy -c docker-compose-prometheus.yml monitor

sleep 10
sh reload.sh