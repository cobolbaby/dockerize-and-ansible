#! /bin/bash

REGISTRY=registry.com:5000
NAME=cobol/nginx:latest

docker build -t $NAME .
docker tag $NAME ${REGISTRY}/$NAME
docker push ${REGISTRY}/$NAME