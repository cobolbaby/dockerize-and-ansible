#! /bin/bash
cd `dirname $0`

PROXY=http://10.190.81.209:3389/
VERSION=latest
GO_VERSION=1.22.8

docker build --rm -f Dockerfile \
            -t registry.inventec/infra/debugger:${VERSION} \
            --build-arg http_proxy=${PROXY} \
            --build-arg https_proxy=${PROXY} \
            --build-arg GO_VERSION=${GO_VERSION} \
            .

# docker run -it --rm --name toolbox --net host registry.inventec/infra/debugger /bin/bash
# go tool pprof -http :??? http://localhost:6060/debug/pprof/heap
