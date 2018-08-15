#!/bin/bash
. ./init.sh

if [ ! -d $MASTER_DATA_PATH ];then
    mkdir -p $MASTER_DATA_PATH
    chmod -R 777 $MASTER_DATA_PATH
fi

# 创建网络

# 从config/etc_host中查询出相关主机地址，ansible批量同步

docker run -dit --rm --name=gpdb --net=host -h mdw -v "$PWD"/config/etc_hosts:/etc/hosts -v "$PWD"/config:/opt/greenplum/config -v ${MASTER_DATA_PATH}:/data/greenplum/master ${REGISTRY}/${TAGNAME}