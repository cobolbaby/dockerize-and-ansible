#!/bin/bash
. ./init.sh

REGISTRY=registry.inventec

INVENTORY_FILE=../inventory.prod

# 传出配置文件
ansible -i $INVENTORY_FILE spark-master -m copy -a "src=deploy.prod/ dest=/opt/spark"
ansible -i $INVENTORY_FILE spark -m file -a "dest=/disk6/spark mode=777 state=directory" -f 5 -b
ansible -i $INVENTORY_FILE spark -m file -a "dest=/disk6/spark/spark-events mode=777 state=directory" -f 5 -b

# 执行启动命令
ansible -i $INVENTORY_FILE sparkmaster -m command -a "/opt/spark/start.sh ${REGISTRY} ${TAGNAME}" -b