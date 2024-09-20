#!/bin/bash
set -e
cd `dirname $0`

PROXY=http://10.190.81.209:3389/
PG_VERSION=16.4

cd build

# docker buildx rm container-builder

# docker buildx create \
#   --name container-builder \
#   --driver docker-container \
#   --use --bootstrap

# 遇到了 registry.inventec 无法解析和证书的问题
# https://github.com/docker/buildx/issues/835

docker buildx build --rm -f Dockerfile \
            -t registry.inventec/infra/postgres:${PG_VERSION} \
            --build-arg PG_VERSION=${PG_VERSION} \
            --build-arg http_proxy=${PROXY} \
            --build-arg https_proxy=${PROXY} \
            .
            # --platform linux/amd64,linux/arm64 \
docker push registry.inventec/infra/postgres:${PG_VERSION}
