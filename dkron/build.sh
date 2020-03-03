#!/bin/bash
set -e
cd `dirname $0`

REGISTRY=registry.inventec
DKRON_VERSION=1.2.5
PROXY=http://10.190.40.39:12317/

docker build --rm -f Dockerfile \
            -t ${REGISTRY}/infra/dkron:${DKRON_VERSION} \
            --build-arg DKRON_VERSION=${DKRON_VERSION} \
            --build-arg http_proxy=${PROXY} \
            --build-arg https_proxy=${PROXY} \
            .
docker push ${REGISTRY}/infra/dkron:${DKRON_VERSION}
