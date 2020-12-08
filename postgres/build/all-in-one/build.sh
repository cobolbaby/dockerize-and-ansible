#!/bin/bash
set -e
cd `dirname $0`

PROXY=http://10.190.40.39:2379/

docker build --rm -f Dockerfile \
            -t registry.inventec/infra/postgres:12.5 \
            --build-arg http_proxy=${PROXY} \
            --build-arg https_proxy=${PROXY} \
            .
docker push registry.inventec/infra/postgres:12.5
