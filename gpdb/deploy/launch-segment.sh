#!/bin/bash
. ../init.sh

if [ ! -d $PRIMARY_DATA_PATH ];then
    mkdir -p $PRIMARY_DATA_PATH
    chmod -R 777 $PRIMARY_DATA_PATH
fi
if [ ! -d $MIRROR_DATA_PATH ];then
    mkdir -p $MIRROR_DATA_PATH
    chmod -R 777 $MIRROR_DATA_PATH
fi

docker pull ${REGISTRY}/$TAGNAME
docker run -dit --rm --name=gpdb --net=host -h sdw1 -v "$PWD"/config/etc_hosts:/etc/hosts -v "$PWD"/config:/opt/greenplum/config -v ${PRIMARY_DATA_PATH}:/data/greenplum/primary -v ${MIRROR_DATA_PATH}:/data/greenplum/mirror ${REGISTRY}/${TAGNAME}