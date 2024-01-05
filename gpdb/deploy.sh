#!/bin/bash
cd `dirname $0`

INVENTORY=../inventory.dev

# 创建挂载在外部的数据目录
# ansible -i $INVENTORY gpdb -m raw -a "ls -la /data/ssd*/gp6data/*"
# ansible -i $INVENTORY gpdb_segment -m file -a "dest=/data/hdd3/gp6data/gpsegment/primary mode=777 state=directory" -b
# ansible -i $INVENTORY gpdb_segment -m file -a "dest=/data/hdd3/gp6data/gpsegment/mirror mode=777 state=directory" -b
# ansible -i $INVENTORY gpdb_segment -m file -a "dest=/data/hdd4/gp6data/gpsegment/primary mode=777 state=directory" -b
# ansible -i $INVENTORY gpdb_segment -m file -a "dest=/data/hdd4/gp6data/gpsegment/mirror mode=777 state=directory" -b
# ansible -i $INVENTORY gpdb_segment -m file -a "dest=/data/ssd3/gp6space mode=777 state=directory" -b
# ansible -i $INVENTORY gpdb_master  -m file -a "dest=/data/ssd2/gp6data/gpmaster mode=777 state=directory" -b
# exit

# 部署新版時一定要先停掉数据库，否则Greenplum启动的时候可能会经历长时间的恢复
# ansible -i $INVENTORY gpdb_mdw  -m raw -a "docker exec -ti gp6mdw /opt/greenplum/config/gpstop.sh"
# ansible -i $INVENTORY gpdb_mdw  -m shell -a "cd /opt/bdcc/greenplum6/bin && docker-compose -f docker-compose-master.yml down"
# ansible -i $INVENTORY gpdb_sdw1 -m shell -a "cd /opt/bdcc/greenplum6/bin && docker-compose -f docker-compose-segment.1.yml down"
# ansible -i $INVENTORY gpdb_sdw2 -m shell -a "cd /opt/bdcc/greenplum6/bin && docker-compose -f docker-compose-segment.2.yml down"
# ansible -i $INVENTORY gpdb_sdw3 -m shell -a "cd /opt/bdcc/greenplum6/bin && docker-compose -f docker-compose-segment.3.yml down"
# ansible -i $INVENTORY gpdb_smdw -m shell -a "cd /opt/bdcc/greenplum6/bin && docker-compose -f docker-compose-standby.yml down"
# exit

# 同步配置文件
ansible -i $INVENTORY gpdb_master -m copy -a "src=deploy/config dest=/opt/bdcc/greenplum6"
ansible -i $INVENTORY gpdb        -m copy -a "src=deploy/bin dest=/opt/bdcc/greenplum6" -f 5

# 执行启动命令
ansible -i $INVENTORY gpdb_sdw1 -m shell -a "cd /opt/bdcc/greenplum6/bin && docker-compose -f docker-compose-segment.1.yml up -d"
ansible -i $INVENTORY gpdb_sdw2 -m shell -a "cd /opt/bdcc/greenplum6/bin && docker-compose -f docker-compose-segment.2.yml up -d"
ansible -i $INVENTORY gpdb_sdw3 -m shell -a "cd /opt/bdcc/greenplum6/bin && docker-compose -f docker-compose-segment.3.yml up -d"
ansible -i $INVENTORY gpdb_smdw -m shell -a "cd /opt/bdcc/greenplum6/bin && docker-compose -f docker-compose-standby.yml up -d"
ansible -i $INVENTORY gpdb_mdw  -m shell -a "cd /opt/bdcc/greenplum6/bin && docker-compose -f docker-compose-master.yml up -d"
