#!/bin/bash
set -e
cd `dirname $0`

. ./init.dev.sh
. ./clean.sh

cd build
docker build --rm -f Dockerfile -t ${REGISTRY}/${TAGNAME} --build-arg http_proxy=${PROXY} --build-arg https_proxy=${PROXY} .
docker push ${REGISTRY}/$TAGNAME