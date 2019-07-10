#!/bin/sh
set -e
cd `dirname $0`

REGISTRY=registry.inventec
TAGNAME=development/openjdk:8-jdk
PROXY=http://10.190.40.39:12306/

cd docker
# mvn clean package
cp -rf ../release .

docker build --rm -f Dockerfile -t ${REGISTRY}/${TAGNAME} --build-arg http_proxy=${PROXY} --build-arg https_proxy=${PROXY} .
# docker push ${REGISTRY}/$TAGNAME

rm -rf release