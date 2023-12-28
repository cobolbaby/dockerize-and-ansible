#!/bin/bash
set -e
cd `dirname $0`

REGISTRY=registry.inventec
STREAMPARK_VERSION=v2.1.2

docker build --rm -f Dockerfile \
            -t ${REGISTRY}/infra/streampark:${STREAMPARK_VERSION} \
            --build-arg STREAMPARK_VERSION=${STREAMPARK_VERSION} \
            .
docker push ${REGISTRY}/infra/streampark:${STREAMPARK_VERSION} 
