#!/bin/bash

# docker swarm init --advertise-addr 10.3.205.79
# docker swarm join --token SWMTKN-1-0pwdwf6onv7d9167s6p6cgt7hecw1hp2ghjn1trd5ou9z282lx-5pq983pml7vf47h8ggfmzv230 10.3.205.79:2377
# docker node update --label-add alias=bdc01.infra.prod.tao.itc.inventec tao-infra-01
# docker node update --label-add alias=bdc02.infra.prod.tao.itc.inventec tao-infra-02
# docker node update --label-add alias=bdc03.infra.prod.tao.itc.inventec tao-infra-03
# docker node promote tao-infra-02
# docker node promote tao-infra-03
# docker network create --driver overlay --subnet=10.13.0.0/16 --attachable bdc

# 推送启动脚本至部署目录
INVENTORY_FILE=../inventory.tao

# 部署文件
# 创建数据目录
# 启动服务

# 传出配置文件
ansible -i $INVENTORY_FILE patroni1 -m copy -a "src=deploy.tao/bin dest=/opt/patroni"
# ansible -i $INVENTORY_FILE patroni1 -m raw -a "docker stack rm pgcluster"
# etcdctl rm /service/pgcluster_tao -r
# ansible -i $INVENTORY_FILE patroni -m file -a "path=/data/ssd/postgres/10.9/data state=absent"
# ansible -i $INVENTORY_FILE patroni -m file -a "dest=/data/ssd/postgres/10.9/data owner=999 group=999 mode=700 state=directory"

# 执行启动命令
ansible -i $INVENTORY_FILE patroni1 -m raw -a "/opt/patroni/bin/start.sh"