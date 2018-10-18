#!/bin/bash
. ./init.sh

# 判断是否存在Ansible
_=`command -v ansible`
if [ $? -ne 0 ]; then
  printf "You don\'t seem to install %s.\n" Ansible
  exit
fi

# 传输文件
ansible -i $INVENTORY_FILE master -m copy -a "src=deploy/ dest=/opt/sparkv2"
ansible -i $INVENTORY_FILE all -m file -a "dest=/disk6/spark mode=777 state=directory" -b

# 执行启动命令
ansible -i $INVENTORY_FILE all -m raw -a "docker pull ${REGISTRY}/${TAGNAME}" -f 5 -b
ansible -i $INVENTORY_FILE master -m command -a "/opt/sparkv2/start.sh ${REGISTRY} ${TAGNAME}" -b