#!/bin/bash

# docker swarm init --advertise-addr 10.191.7.12
# docker swarm join --token SWMTKN-1-4a0kd489eyungysrlcx2e1vtlplxvmv91kk26e4oi9jfmzc2ty-68e0luv5dvzigxa9korch34y7 10.191.7.12:2377
# docker node promote kubernetes-4
# docker node promote kubernetes-5
# docker node update --label-add alias=bdc06.infra.dev.tj.itc.inventec kubernetes-2
# docker node update --label-add alias=bdc07.infra.dev.tj.itc.inventec kubernetes-4
# docker node update --label-add alias=bdc08.infra.dev.tj.itc.inventec kubernetes-5
# docker network create --driver overlay --subnet=10.13.0.0/16 --attachable bdc

# 推送启动脚本至部署目录
INVENTORY_FILE=../inventory.dev

# ansible -i $INVENTORY_FILE patroni1 -m raw -a "docker stack rm postgres"
ansible -i $INVENTORY_FILE patroni1 -m raw -a "docker-compose -f /opt/patroni/keepalived/docker-compose-keepalived-master.yml down"
ansible -i $INVENTORY_FILE patroni2 -m raw -a "docker-compose -f /opt/patroni/keepalived/docker-compose-keepalived-standby.yml down"
ansible -i $INVENTORY_FILE patroni3 -m raw -a "docker-compose -f /opt/patroni/keepalived/docker-compose-keepalived-standby2.yml down"
# etcdctl rm /pgcluster/pgcluster_itc -r
# exit

# 部署文件
# 创建数据目录
# ansible -i $INVENTORY_FILE patroni -m file -a "path=/data-ssd/postgres/10/data state=absent"
# ansible -i $INVENTORY_FILE patroni -m file -a "dest=/data-ssd/postgres/10/data owner=999 group=999 mode=700 state=directory" -b

# 传出配置文件
ansible -i $INVENTORY_FILE patroni1 -m copy -a "src=deploy.dev/bin dest=/opt/patroni"

# 执行启动命令
ansible -i $INVENTORY_FILE patroni1 -m raw -a "chmod +x /opt/patroni/bin/start.sh"
ansible -i $INVENTORY_FILE patroni1 -m raw -a "/opt/patroni/bin/start.sh"

# Keepalived
# ansible -i $INVENTORY_FILE patroni -m file -a "path=/opt/patroni/keepalived state=absent"
# ansible -i $INVENTORY_FILE patroni -m raw -a "docker pull registry.inventec/infra/keepalived:2.0.17" -f 5 -b
ansible -i $INVENTORY_FILE patroni -m copy -a "src=deploy.dev/keepalived dest=/opt/patroni"
ansible -i $INVENTORY_FILE patroni1 -m raw -a "docker-compose -f /opt/patroni/keepalived/docker-compose-keepalived-master.yml up -d"
ansible -i $INVENTORY_FILE patroni2 -m raw -a "docker-compose -f /opt/patroni/keepalived/docker-compose-keepalived-standby.yml up -d"
ansible -i $INVENTORY_FILE patroni3 -m raw -a "docker-compose -f /opt/patroni/keepalived/docker-compose-keepalived-standby2.yml up -d"
