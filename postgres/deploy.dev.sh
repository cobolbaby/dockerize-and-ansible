#!/bin/bash
cd `dirname $0`

# docker swarm init --advertise-addr 10.191.7.12
# docker swarm join --token SWMTKN-1-14hlcs07jekxx3260bu1q42s7lwa8nvybz4e4eu4ey4qzz59ay-bac89hu6qm8z9d07qkvoqgxq8 10.191.7.12:2377
# docker node promote kubernetes-4
# docker node promote kubernetes-5
# docker node update --label-add alias=bdc06.infra.dev.itc.inventec kubernetes-2
# docker node update --label-add alias=bdc07.infra.dev.itc.inventec kubernetes-4
# docker node update --label-add alias=bdc08.infra.dev.itc.inventec kubernetes-5
# docker network create --driver overlay --subnet=10.13.0.0/16 --attachable bdc

INVENTORY_FILE=../inventory.dev

# ansible -i $INVENTORY_FILE patroni1 -m raw -a "docker stack rm postgres"
# ansible -i $INVENTORY_FILE patroni1 -m raw -a "docker-compose -f /opt/patroni/keepalived/docker-compose-keepalived-master.yml down"
# ansible -i $INVENTORY_FILE patroni2 -m raw -a "docker-compose -f /opt/patroni/keepalived/docker-compose-keepalived-standby.yml down"
# ansible -i $INVENTORY_FILE patroni3 -m raw -a "docker-compose -f /opt/patroni/keepalived/docker-compose-keepalived-standby2.yml down"
# exit

# 创建数据目录
ansible -i $INVENTORY_FILE patroni -m file -a "dest=/data/hdd/pg/12/data owner=999 group=999 mode=700 state=directory" -b
ansible -i $INVENTORY_FILE patroni -m file -a "dest=/data/ssd/pg/12 owner=999 group=999 mode=700 state=directory" -b
ansible -i $INVENTORY_FILE patroni -m file -a "dest=/data/ssd/pg/12/data owner=999 group=999 mode=700 state=directory" -b

# 推送启动脚本至部署目录
# 传出配置文件
ansible -i $INVENTORY_FILE patroni -m copy -a "src=deploy.dev/ dest=/opt/patroni"

# 执行启动命令
ansible -i $INVENTORY_FILE patroni1 -m raw -a "chmod +x /opt/patroni/bin/start.sh"
ansible -i $INVENTORY_FILE patroni1 -m raw -a "/opt/patroni/bin/start.sh"
# exit
# Keepalived
ansible -i $INVENTORY_FILE patroni -m raw -a "chmod +x /opt/patroni/keepalived/*/*.sh"
ansible -i $INVENTORY_FILE patroni -m raw -a "chmod 644 /opt/patroni/keepalived/*/*.conf"
# ansible -i $INVENTORY_FILE patroni -m raw -a "docker pull registry.inventec/infra/keepalived:2.0.17" -f 5
ansible -i $INVENTORY_FILE patroni1 -m raw -a "docker-compose -f /opt/patroni/keepalived/docker-compose-keepalived-master.yml up -d"
ansible -i $INVENTORY_FILE patroni2 -m raw -a "docker-compose -f /opt/patroni/keepalived/docker-compose-keepalived-standby.yml up -d"
ansible -i $INVENTORY_FILE patroni3 -m raw -a "docker-compose -f /opt/patroni/keepalived/docker-compose-keepalived-standby2.yml up -d"
