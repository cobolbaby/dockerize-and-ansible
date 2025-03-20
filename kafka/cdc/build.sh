#!/bin/bash
set -e
cd `dirname $0`

REGISTRY=registry.inventec

docker build --rm -f Dockerfile \
    -t ${REGISTRY}/infra/cdc-guard:latest \
     .
docker push ${REGISTRY}/infra/cdc-guard:latest

