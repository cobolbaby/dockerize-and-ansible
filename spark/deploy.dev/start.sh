#!/bin/bash
set -e

cd `dirname $0`

echo "启动参数: $*"
export REGISTRY="$1"
export TAGNAME="$2"
# export EXTERNAL_IP=`hostname -I | cut -d " " -f 1`

docker stack deploy -c docker-compose-master.yml spark_master
sleep 20
docker stack deploy -c docker-compose-worker.yml spark_worker