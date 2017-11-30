#! /bin/bash

REGISTRY=registry.com:5000
NAME=cobol/nodejs:latest

docker build -t $NAME .
docker tag $NAME ${REGISTRY}/$NAME
docker push ${REGISTRY}/$NAME