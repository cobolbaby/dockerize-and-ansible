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

# gpstart pending...
# 看启动日志是说找不到扩展so，所以禁用以下的扩展
# 类似问题: http://gpcc.docs.pivotal.io/4100/topics/troubleshooting-wlm.html
# gpssh -f /opt/greenplum/config/seg_hosts -e "grep -i shared_preload_libraries /disk[1-3]/gpdata/gpsegment/*/*/postgresql.conf"
# gpssh -f /opt/greenplum/config/seg_hosts -e "sed -rn 's/^shared_preload_libraries/#shared_preload_libraries/p' /disk[1-3]/gpdata/gpsegment/*/*/postgresql.conf"
# gpssh -f /opt/greenplum/config/seg_hosts -e "sed -ri 's/^shared_preload_libraries/#shared_preload_libraries/g' /disk[1-3]/gpdata/gpsegment/*/*/postgresql.conf"
# sed -ri 's/^shared_preload_libraries/#shared_preload_libraries/g' $MASTER_DATA_DIRECTORY/postgresql.conf

# 为啥build出来的是5.0.版本，我下的源码使5.28.1
