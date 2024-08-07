#!/bin/bash
set -e
cd `dirname $0`

PROXY=http://10.190.81.209:3389/
PG_VERSION=16.3

cd build

docker build --rm -f Dockerfile \
            -t registry.inventec/infra/postgres:${PG_VERSION} \
            --build-arg PG_VERSION=${PG_VERSION} \
            --build-arg http_proxy=${PROXY} \
            --build-arg https_proxy=${PROXY} \
            .
docker push registry.inventec/infra/postgres:${PG_VERSION}
