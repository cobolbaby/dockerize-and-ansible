#!/bin/bash
cd /opt/greenplum

docker stack rm gpdb_master
docker stack rm gpdb_segment
sleep 10  # 等10秒后执行下一条

docker stack deploy -c docker-compose-segment.yml gpdb_segment
sleep 30  # 等30秒后执行下一条
docker stack deploy -c docker-compose-master.yml gpdb_master