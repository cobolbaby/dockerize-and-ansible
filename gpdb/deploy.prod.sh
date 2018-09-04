#!/bin/bash
. ./init.prod.sh

# 可否一次性定义inventory
INVENTORY=./inventory.prod

# 添加私有仓库地址
# ansible -i $INVENTORY all -m shell -a "echo '10.99.170.92    harbor.remote.inventec.com' >> /etc/hosts" -b
# ansible -i $INVENTORY all -m copy -a "src=../docker-daemon.json dest=/etc/docker/daemon.json" -b
# ansible -i $INVENTORY all -m service -a "name=docker state=restarted" -b

# 创建数据目录
# ansible -i $INVENTORY gpdb-master  -m file -a "dest=/disk1/greenplum/master mode=777 state=directory"
# ansible -i $INVENTORY gpdb-segment -m file -a "dest=/disk1/greenplum/primary mode=777 state=directory" -f 5
# ansible -i $INVENTORY gpdb-segment -m file -a "dest=/disk1/greenplum/mirror mode=777 state=directory" -f 5
# ansible -i $INVENTORY gpdb-segment -m file -a "dest=/disk2/greenplum/primary mode=777 state=directory" -f 5
# ansible -i $INVENTORY gpdb-segment -m file -a "dest=/disk2/greenplum/mirror mode=777 state=directory" -f 5
# ansible -i $INVENTORY gpdb-segment -m file -a "dest=/disk3/greenplum/primary mode=777 state=directory" -f 5
# ansible -i $INVENTORY gpdb-segment -m file -a "dest=/disk3/greenplum/mirror mode=777 state=directory" -f 5

# 同步配置文件
ansible -i $INVENTORY gpdb-master -m copy -a "src='deploy.prod/' dest='/opt/greenplum'"

# 执行启动命令
ansible -i $INVENTORY all -m command -a "docker pull ${REGISTRY}/${TAGNAME}" -b -f 5
ansible -i $INVENTORY gpdb-master -m command -a "/opt/greenplum/start.sh ${REGISTRY} ${TAGNAME}" -b

# 添加附加程序
# ansible -i $INVENTORY all  -m apt -a "name=iftop state=latest install_recommends=no" -b -f 5
