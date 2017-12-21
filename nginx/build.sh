#!/bin/bash
. ./init.sh

docker build --rm -f Dockerfile -t $TAGNAME .
docker tag $TAGNAME ${REGISTRY}/$TAGNAME
docker push ${REGISTRY}/$TAGNAME