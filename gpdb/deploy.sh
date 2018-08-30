#!/bin/bash
. ./init.sh

# 可否一次性定义inventory
INVENTORY=./inventory.dev

# ansible -i $INVENTORY gpdb-segment -m command -a "docker swarm leave" -b -f 5
# ansible -i $INVENTORY gpdb-master -m command -a "docker swarm leave --force" -b
# 初始化Swarm
# sudo docker swarm init --advertise-addr 10.190.5.110
# ansible -i $INVENTORY gpdb-segment -m command -a "docker swarm join --token SWMTKN-1-4126cihsbxke80im4rb3rbb5244jd0v16t3da7v2vdc91woqrw-71dtnptvr1vuc7siuc0z2ravb 10.190.5.110:2377" -b
# ansible -i $INVENTORY gpdb-master -m command -a "docker node ls" -b

# 初始化网络
# record=`docker network ls | awk '($2=="gpdb"){print $1}' | wc -l`
# if [ $record -gt 0 ]; then
#     docker network rm gpdb
# fi
# ansible -i $INVENTORY gpdb-master -m command -a "docker network create --driver overlay gpdb" -b
ansible -i $INVENTORY all -m command -a "docker network ls" -b

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