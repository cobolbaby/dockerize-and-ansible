#!/bin/bash
set -e
cd `dirname $0`

REGISTRY=registry.inventec
PROXY=http://10.190.40.39:2379/

docker build --rm -f Dockerfile \
            -t ${REGISTRY}/development/datahub:v0.4.1 \
            --build-arg http_proxy=${PROXY} \
            --build-arg https_proxy=${PROXY} \
            .
docker push ${REGISTRY}/development/datahub:v0.4.1
