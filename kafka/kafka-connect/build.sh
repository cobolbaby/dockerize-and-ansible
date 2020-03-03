#!/bin/bash
set -e
cd `dirname $0`

REGISTRY=registry.inventec
TAGNAME=development/cp-kafka-connect:5.3.1-p3
PROXY=http://10.190.40.39:12306/

docker build --rm -f Dockerfile -t ${REGISTRY}/${TAGNAME} --build-arg http_proxy=${PROXY} --build-arg https_proxy=${PROXY} .
docker push ${REGISTRY}/$TAGNAME