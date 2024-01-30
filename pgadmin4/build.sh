#! /bin/bash
cd `dirname $0`

PROXY=http://10.190.81.209:3389/
VERSION=5.7

# git clone https://github.com/pgadmin-org/pgadmin4.git
# cd pgadmin4
# git checkout REL-5_7
# git apply gpdb6-support.patch
# make docker

docker build --rm -f Dockerfile \
            -t registry.inventec/infra/dpage/pgadmin4:${VERSION} \
            --build-arg http_proxy=${PROXY} \
            --build-arg https_proxy=${PROXY} \
            --build-arg VERSION=${VERSION} \
            .
