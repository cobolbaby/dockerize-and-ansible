#!/bin/bash
# 初始化Greenplum的环境变量，以便执行gpstart
source /usr/local/greenplum-db/greenplum_path.sh
# echo "gpstart command path is `which gpstart`"
# 启动sshd
/usr/sbin/sshd

# 临时脚本，用于维持容器抓状态
while true; do echo 'Greenplum is running'; sleep 60; done

# TODO::主节点每次启动创建互信以及`gpstart -a`