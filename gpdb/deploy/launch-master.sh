#!/bin/bash
. ../init.sh

if [ ! -d $MASTER_DATA_PATH ];then
    mkdir -p $MASTER_DATA_PATH
    chmod -R 777 $MASTER_DATA_PATH
fi

docker pull ${REGISTRY}/$TAGNAME
docker run -dit --rm --name=gpdb --net=host -h mdw -v "$PWD"/config/etc_hosts:/etc/hosts -v "$PWD"/config:/opt/greenplum/config -v ${MASTER_DATA_PATH}:/data/greenplum/master ${REGISTRY}/${TAGNAME}