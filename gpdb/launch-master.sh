#!/bin/bash
. ./init.sh

mkdir -p $MASTER_DATA_PATH
chmod -R 777 $MASTER_DATA_PATH
docker run -d --rm --name=gpdb --net=host -v "$PWD"/config/etc_hosts:/etc/hosts -v "$PWD"/config:/opt/greenplum/config -v ${MASTER_DATA_PATH}:/data/greenplum/master ${REGISTRY}/${TAGNAME}