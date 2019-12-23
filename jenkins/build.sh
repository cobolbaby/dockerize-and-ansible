#!/bin/bash
set -e
cd `dirname $0`

REGISTRY=registry.inventec
PROXY=http://10.190.40.39:12306/
VERSION=2.204.1-centos

docker build --rm -f Dockerfile \
            -t ${REGISTRY}/development/jenkins:${VERSION} \
            --build-arg http_proxy=${PROXY} \
            --build-arg https_proxy=${PROXY} \
            --build-arg VERSION=${VERSION} \
            .
docker push ${REGISTRY}/development/jenkins:${VERSION}
