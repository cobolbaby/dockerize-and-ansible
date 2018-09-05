#!/bin/bash
# INVENTORY=./inventory.prod
# INVENTORY=./inventory.dev

# TODO::判断是否安装了docker

# ansible -i $INVENTORY slave -m command -a "docker swarm leave" -b -f 5
# ansible -i $INVENTORY master -m command -a "docker swarm leave --force" -b
# 初始化Swarm
# sudo docker swarm init --advertise-addr 10.190.5.110
# ansible -i $INVENTORY slave -m command -a "docker swarm join --token SWMTKN-1-0j3fwj7l94d7r4yn2c2yud4d9l0084wzugbikneqp19anwo4vm-8z7ebejale5d89mouy81zbla0 10.190.5.110:2377" -b
# ansible -i $INVENTORY master -m command -a "docker node ls" -b

# 初始化网络
# record=`docker network ls | awk '($2=="gpdb"){print $1}' | wc -l`
# if [ $record -gt 0 ]; then
#     docker network rm gpdb
# fi
# ansible -i $INVENTORY master -m command -a "docker network create --driver overlay --attachable gpdb" -b
# ansible -i $INVENTORY master -m command -a "docker network ls" -b