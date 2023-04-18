#!/bin/bash
cd `dirname $0`

# 前置操作:
# docker network create --driver bridge --subnet=10.14.0.0/16 infra

INVENTORY_FILE=../inventory.dev

# 创建数据目录
ansible -i $INVENTORY_FILE postgres -m file -a "dest=/data/hdd/pg/12/data owner=999 group=999 mode=700 state=directory" -b
ansible -i $INVENTORY_FILE postgres -m file -a "dest=/data/ssd/pg/12/data owner=999 group=999 mode=700 state=directory" -b

# 传出配置文件
ansible -i $INVENTORY_FILE postgres -m copy -a "src=deploy.dev/ dest=/opt/postgres" -b

# 执行启动命令
ansible -i $INVENTORY_FILE pg01 -m raw -a "cd /opt/postgres/bin && docker-compose -f docker-compose-pg01.yml up -d"
ansible -i $INVENTORY_FILE pg02 -m raw -a "cd /opt/postgres/bin && docker-compose -f docker-compose-pg02.yml up -d"
# Keepalived
ansible -i $INVENTORY_FILE postgres -m raw -a "chmod +x /opt/postgres/keepalived/*/*.sh" -b
ansible -i $INVENTORY_FILE pg01 -m raw -a "cd /opt/postgres/keepalived && docker-compose -f docker-compose-keepalived-master.yml up -d"
ansible -i $INVENTORY_FILE pg02 -m raw -a "cd /opt/postgres/keepalived && docker-compose -f docker-compose-keepalived-standby.yml up -d"
