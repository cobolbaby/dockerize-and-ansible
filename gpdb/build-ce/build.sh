#!/bin/bash
set -e
cd `dirname $0`

. ../init.dev.sh

TAGNAME=development/gpdb:5.28.1-ce

docker build --rm -f Dockerfile.ce -t ${REGISTRY}/${TAGNAME} \
            --build-arg http_proxy=${PROXY} --build-arg https_proxy=${PROXY} \
            .
docker push ${REGISTRY}/$TAGNAME
