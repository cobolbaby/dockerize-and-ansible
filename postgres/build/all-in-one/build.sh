#!/bin/bash
set -e
cd `dirname $0`

PROXY=http://10.190.40.39:12317/

docker build --rm -f Dockerfile \
            -t registry.inventec/infra/postgres:11.8-partman-4.4.0 \
            --build-arg http_proxy=${PROXY} \
            --build-arg https_proxy=${PROXY} \
            .
docker push registry.inventec/infra/postgres:11.8-partman-4.4.0
