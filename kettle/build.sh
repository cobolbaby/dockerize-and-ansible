#! /bin/bash
cd `dirname $0`

PROXY=http://10.190.81.209:3389/
KETTLE_BRANCH=9.5

docker build --rm -f Dockerfile \
            -t registry.inventec/infra/kettle:${KETTLE_BRANCH} \
            --build-arg http_proxy=${PROXY} \
            --build-arg https_proxy=${PROXY} \
            --build-arg no_proxy=localhost,127.0.0.1,nexus.itc.inventec.net \
            --build-arg KETTLE_BRANCH=${KETTLE_BRANCH} \
            .

