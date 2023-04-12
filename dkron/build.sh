#!/bin/bash
set -e
cd `dirname $0`

[[ $# -lt 1 ]] && {
  echo "Usage: $0 proxy:port"
  exit 1
}

proxy=$1

REGISTRY=registry.inventec
DKRON_VERSION=3.2.3
OPENJDK_VERSION=8u342-jre-slim-buster

docker build --rm -f Dockerfile \
            -t ${REGISTRY}/infra/dkron-executor-docker:${DKRON_VERSION} \
            --build-arg http_proxy=http://${proxy} \
            --build-arg https_proxy=http://${proxy} \
            --build-arg DKRON_VERSION=${DKRON_VERSION} \
            --build-arg OPENJDK_VERSION=${OPENJDK_VERSION} \
            .
docker push ${REGISTRY}/infra/dkron-executor-docker:${DKRON_VERSION} 
