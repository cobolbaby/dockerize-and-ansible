#!/bin/bash
. ./init.sh

# 可否一次性定义inventory
INVENTORY=./inventory.dev

# 初次创建数据目录
ansible -i $INVENTORY gpdb-master -m file -a "dest=/disk1/gpdata/gpmaster mode=777 state=directory" -b
ansible -i $INVENTORY gpdb-segment -m file -a "dest=/disk2/greenplum/primary mode=777 state=directory" -f 5 -b
ansible -i $INVENTORY gpdb-segment -m file -a "dest=/disk2/greenplum/mirror mode=777 state=directory" -f 5 -b
ansible -i $INVENTORY gpdb-segment -m file -a "dest=/disk3/greenplum/primary mode=777 state=directory" -f 5 -b
ansible -i $INVENTORY gpdb-segment -m file -a "dest=/disk3/greenplum/mirror mode=777 state=directory" -f 5 -b

# 传出配置文件
ansible -i $INVENTORY gpdb-master -m copy -a "src='deploy/' dest='/opt/greenplum'" -b
ansible -i $INVENTORY gpdb-segment -m file -a "path=/opt/greenplum state=absent" -b
# ansible -i $INVENTORY gpdb-segment -m copy -a "src=deploy/config dest=/opt/greenplum" -b

# 执行启动命令
ansible -i $INVENTORY gpdb-master -m command -a "/opt/greenplum/start.sh ${REGISTRY} ${TAGNAME}" -b