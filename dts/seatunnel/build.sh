#! /bin/bash
cd `dirname $0`

PROXY=http://10.190.81.209:3389/
SEATUNNEL_VERSION=2.3.5

docker build --rm -f Dockerfile \
            -t registry.inventec/infra/seatunnel:${SEATUNNEL_VERSION} \
            --build-arg http_proxy=${PROXY} \
            --build-arg https_proxy=${PROXY} \
            --build-arg no_proxy=localhost,127.0.0.1,*.itc.inventec.net \
            --build-arg SEATUNNEL_VERSION=${SEATUNNEL_VERSION} \
            .

docker push registry.inventec/infra/seatunnel:${SEATUNNEL_VERSION}