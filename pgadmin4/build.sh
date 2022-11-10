#! /bin/bash
cd `dirname $0`

PROXY=http://10.190.41.209:3388/
VERSION=5.7

docker build --rm -f Dockerfile \
            -t registry.inventec/infra/dpage/pgadmin4:${VERSION} \
            --build-arg http_proxy=${PROXY} \
            --build-arg https_proxy=${PROXY} \
            --build-arg VERSION=${VERSION} \
            .
