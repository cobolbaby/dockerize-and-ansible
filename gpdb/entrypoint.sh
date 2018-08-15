#!/bin/bash
# 初始化Greenplum的环境变量，以便执行gpstart
source /usr/local/greenplum-db/greenplum_path.sh
# echo "gpstart command path is `which gpstart`"
# 启动sshd
/usr/sbin/sshd

# 临时脚本，用于维持容器抓状态
while true; do echo hello world; sleep 10; done