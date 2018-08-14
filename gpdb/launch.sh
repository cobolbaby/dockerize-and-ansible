#!/bin/bash
. ./init.sh

docker run -d --rm --name=gpdb -h gpdb -p 5432:5432 --net=host ${REGISTRY}/${TAGNAME}