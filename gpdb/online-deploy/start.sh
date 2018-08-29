#!/bin/bash
cd /opt/greenplum

echo "启动参数: $*"
export REGISTRY="$1"
export TAGNAME="$2"

docker stack rm gpdb_master
docker stack rm gpdb_segment
sleep 10  # 等10秒后执行下一条

docker stack deploy -c docker-compose-segment.yml gpdb_segment
sleep 30  # 等30秒后执行下一条
docker stack deploy -c docker-compose-master.yml gpdb_master