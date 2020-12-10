#!/bin/bash
set -e
cd `dirname $0`

PROXY=http://10.190.40.39:2379/
PG_MAJOR=12.5

docker build --rm -f Dockerfile \
            -t registry.inventec/infra/postgres:${PG_MAJOR} \
            --build-arg http_proxy=${PROXY} \
            --build-arg https_proxy=${PROXY} \
            --build-arg PG_MAJOR=${PG_MAJOR} \
            .
docker push registry.inventec/infra/postgres:${PG_MAJOR}
