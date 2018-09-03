#!/bin/bash
. ./init.sh

# 停止运行中的容器
querynum1=`docker ps | grep $TAGNAME | awk '{print $1}' | wc -l`
if [ $querynum1 -gt 0 ]; then
    docker stop $(docker ps | grep $TAGNAME | awk '{print $1}')
fi

# This will remove:
# - all stopped containers
# - all networks not used by at least one container
# - all dangling images
# - all build cache
docker system prune --force