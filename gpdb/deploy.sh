#!/bin/bash
. ./init.sh

if [ ! -d $MASTER_DATA_PATH ];then
    mkdir -p $MASTER_DATA_PATH
    chmod -R 777 $MASTER_DATA_PATH
fi
if [ ! -d $PRIMARY_DATA_PATH ];then
    mkdir -p $PRIMARY_DATA_PATH
    chmod -R 777 $PRIMARY_DATA_PATH
fi
if [ ! -d $MIRROR_DATA_PATH ];then
    mkdir -p $MIRROR_DATA_PATH
    chmod -R 777 $MIRROR_DATA_PATH
fi

# 如何定义初始化函数

sudo docker swarm init --advertise-addr 10.190.5.110

docker swarm join --token SWMTKN-1-44xebmqerko0v8y3mxlaz00xc6supwol8ub4sbs9kvtl1k2rv3-1o9ohpmzpmapl5atgi069w017 10.190.5.110:2377

docker network ls | awk '($2=="gpdb"){print $1}' | wc -l

docker network create --driver overlay gpdb

docker node 

# 传输deploy目录下的文件至/opt/greenplum

# 仅在主节点执行运行操作