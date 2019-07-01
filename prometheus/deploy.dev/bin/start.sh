#!/bin/bash
set -e
cd `dirname $0`

INFLUXDB_ADDR=10.191.7.11
HARBOR_REGISTRY=harbor.inventec.com

export INFLUXDB=${INFLUXDB_ADDR}
export REGISTRY=${HARBOR_REGISTRY}

echo "Harbor仓库地址: ${REGISTRY}"
echo "INFLUXDB地址: ${INFLUXDB}"

docker-compose -f docker-compose-prometheus.yml up -d
