#!/bin/bash
set -e
cd `dirname $0`

REGISTRY=registry.inventec
DKRON_VERSION=1.2.5

docker build --rm -f Dockerfile \
            -t ${REGISTRY}/infra/dkron:${DKRON_VERSION} \
            --build-arg DKRON_VERSION=${DKRON_VERSION} \
            .
docker push ${REGISTRY}/infra/dkron:${DKRON_VERSION}
