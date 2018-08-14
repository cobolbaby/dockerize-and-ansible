#!/bin/bash
. ./init.sh

docker run -d --rm --name=gpdb --net=host -v "$PWD"/config/etc_hosts:/etc/hosts -v "$PWD"/config:/opt/greenplum/config ${REGISTRY}/${TAGNAME}