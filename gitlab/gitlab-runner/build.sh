#!/bin/bash
set -e
cd `dirname $0`

PROXY=http://10.190.81.209:3389/

docker build --rm -f Dockerfile.pipeline \
            -t registry.inventec/infra/ci:1.0 \
            --build-arg http_proxy=${PROXY} \
            --build-arg https_proxy=${PROXY} \
            .
docker push registry.inventec/infra/ci:1.0
