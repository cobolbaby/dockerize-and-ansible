#!/bin/bash
. ./init.sh

docker build --rm -f Dockerfile -t ${REGISTRY}/$TAGNAME .
docker push ${REGISTRY}/$TAGNAME