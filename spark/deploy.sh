#!/bin/bash
. ./init.sh

# 传出配置文件
ansible -i $INVENTORY_FILE master -m copy -a "src=deploy/ dest=/opt/sparkv2"

# 执行启动命令
ansible -i $INVENTORY_FILE all -m raw -a "docker pull ${REGISTRY}/${TAGNAME}" -f 5 -b
# ansible -i $INVENTORY_FILE master -m command -a "/opt/sparkv2/start.sh ${REGISTRY} ${TAGNAME}" -b