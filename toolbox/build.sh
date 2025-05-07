#! /bin/bash
cd `dirname $0`

PROXY=http://10.190.81.209:3389/
VERSION=latest
GO_VERSION=1.24.2
MAT_VERSION=1.16.1.20250109

docker build --rm -f Dockerfile \
            -t registry.inventec/infra/debugger:${VERSION} \
            --build-arg http_proxy=${PROXY} \
            --build-arg https_proxy=${PROXY} \
            --build-arg GO_VERSION=${GO_VERSION} \
            --build-arg MAT_VERSION=${MAT_VERSION} \
            .
