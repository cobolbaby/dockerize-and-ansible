#!/bin/bash
set -e
cd `dirname $0`

. ./init.sh
. ./clean.sh

cd build-ce
docker build --rm \
        -t ${REGISTRY}/${TAGNAME}-ce \
        --build-arg http_proxy=${PROXY} \
        --build-arg https_proxy=${PROXY} \
        .
docker push ${REGISTRY}/$TAGNAME-ce