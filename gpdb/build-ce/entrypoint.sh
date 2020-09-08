#!/bin/bash
# set -e

# 启动SSH
sudo /usr/sbin/sshd

# 如果不source，后续的指令将无法执行
source /home/gpadmin/.bashrc
which gpstart

# 启动GPDB
if [ `hostname` == "mdw" ]; then
    gpssh-exkeys -f config/hostlist
    echo "Key exchange complete"
    gpstart -a
else
    echo "NODE is: `hostname`"
fi

if [ -z "$1" ]; then
    echo "Greenplum container is healthy" > /opt/greenplum/stdout
    tail -f /opt/greenplum/stdout
else
    "$@"
fi
