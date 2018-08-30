#! /bin/bash
NAME=development/node:8.11
PROXY=http://10.190.40.39:18118/

# 添加TS编译
# gulp build

docker build --rm -f Dockerfile -t $NAME --build-arg http_proxy=${PROXY} --build-arg https_proxy=${PROXY} .
