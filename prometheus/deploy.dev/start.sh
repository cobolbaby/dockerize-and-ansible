#!/bin/bash
set -e
cd `dirname $0`

export PG_MONITOR_USER=pgexporter PG_MONITOR_PASS=pgexporter
export PG_URI=${PG_HOST}:${PG_PORT}
export GP_URI=${GP_HOST}:${GP_PORT}

docker stack deploy -c docker-compose-prometheus.yml prometheus

sleep 10
sh reload.sh
