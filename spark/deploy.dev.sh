#!/bin/bash
. ./init.sh

REGISTRY=registry.inventec

INVENTORY_FILE=../inventory.dev

# 传出配置文件
ansible -i $INVENTORY_FILE spark-master -m copy -a "src=deploy.dev/ dest=/opt/spark" -b
# ansible -i $INVENTORY_FILE spark -m file -a "dest=/data/ssd0/spark mode=777 state=directory" -f 5 -b
# ansible -i $INVENTORY_FILE spark -m file -a "dest=/data/ssd0/spark/spark-events mode=777 state=directory" -f 5 -b
ansible -i $INVENTORY_FILE spark-slave -m file -a "dest=/data/ssd0/spark/work mode=777 state=directory" -f 5 -b

# 执行启动命令
ansible -i $INVENTORY_FILE sparkmaster -m command -a "/opt/spark/start.sh ${REGISTRY} ${TAGNAME}" -b