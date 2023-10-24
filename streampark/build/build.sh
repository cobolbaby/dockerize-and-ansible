#!/bin/bash
set -e
cd `dirname $0`

REGISTRY=registry.inventec

docker build --rm -f Dockerfile \
            -t ${REGISTRY}/infra/streampark:latest \
            .
docker push ${REGISTRY}/infra/streampark:latest 
