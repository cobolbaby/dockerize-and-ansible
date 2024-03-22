#!/bin/bash
set -e
cd `dirname $0`

REGISTRY=registry.inventec/infra
TAG=7.5.3
PROXY=http://10.190.81.209:3389/

docker build --rm -f Dockerfile \
            -t ${REGISTRY}/confluentinc/cp-kafka-connect:${TAG} \
            --build-arg TAG=${TAG} \
            --build-arg http_proxy=${PROXY} \
            --build-arg https_proxy=${PROXY} \
            .
docker push ${REGISTRY}/confluentinc/cp-kafka-connect:${TAG}
