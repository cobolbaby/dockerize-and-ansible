#! /bin/bash
NAME=cobol/nodejs:8.11

# 添加TS编译
# gulp build

docker build -t $NAME .
