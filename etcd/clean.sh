#!/bin/bash
. ./init.sh

# 停止运行中的容器
querynum1=`docker ps | grep $TAGNAME | awk '{print $1}' | wc -l`
if [ $querynum1 -gt 0 ]; then
    docker stop $(docker ps | grep $TAGNAME | awk '{print $1}')
fi

# 删除停止状态的容器
querynum2=`docker ps -a | grep 'Exited' | awk '{print $1}' | wc -l`
if [ $querynum2 -gt 0 ]; then
    docker rm $(docker ps -a | grep 'Exited' | awk '{print $1}')
fi

# 删除没有标签的镜像
querynum3=`docker images | grep '<none>' | awk '{print $3}' | wc -l`
if [ $querynum3 -gt 0 ]; then
    docker rmi $(docker images | grep '<none>' | awk '{print $3}')
fi