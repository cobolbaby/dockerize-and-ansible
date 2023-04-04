#!/bin/bash
set -e
cd `dirname $0`

PG_VERSION=12.14

cd build

docker build --rm -f Dockerfile \
            -t registry.inventec/infra/postgres:${PG_VERSION} \
            --build-arg PG_VERSION=${PG_VERSION} \
            .
docker push registry.inventec/infra/postgres:${PG_VERSION}
