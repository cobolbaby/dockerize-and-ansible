#! /bin/bash

REGISTRY=registry.com:5000
NAME=binary:super

docker build -t $NAME .
docker tag $NAME ${REGISTRY}/$NAME
docker push ${REGISTRY}/$NAME