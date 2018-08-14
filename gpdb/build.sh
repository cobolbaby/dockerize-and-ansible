#!/bin/bash
. ./init.sh

docker build --rm -f Dockerfile -t ${REGISTRY}/${TAGNAME} --build-arg http_proxy=${PROXY} --build-arg https_proxy=${PROXY} .
# docker push ${REGISTRY}/$TAGNAME