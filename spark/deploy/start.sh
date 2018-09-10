#!/bin/bash
set -e

cd /opt/sparkv2

echo "启动参数: $*"
export REGISTRY="$1"
export TAGNAME="$2"
export EXTERNAL_IP=`hostname -I | cut -d " " -f 1`

docker stack rm spark_worker
docker stack rm spark_master
sleep 10  # 等10秒后执行下一条

docker stack deploy -c docker-compose-master.yml spark_master
sleep 20
docker stack deploy -c docker-compose-worker.yml spark_worker