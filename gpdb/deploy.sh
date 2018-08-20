#!/bin/bash
. ./init.sh

docker network ls | awk '($2=="gpdb"){print $1}' | wc -l

docker network create -d overlay --subnet=172.18.0.0/16 gpdb


# 【可选】依据etc_hosts生成hostlist以及seg_hosts文件

# 传输deploy目录下的文件至/opt/greenplum

# 依据节点的角色执行启动脚本

# 创建网络Swarm还是