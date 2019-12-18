#!/bin/bash
set -e
cd `dirname $0`

REGISTRY=harbor.inventec.com
PROXY=http://10.190.40.39:12306/

docker build --rm -f Dockerfile -t ${REGISTRY}/development/python-36-centos7:20191218 --build-arg http_proxy=${PROXY} --build-arg https_proxy=${PROXY} .
docker push ${REGISTRY}/development/python-36-centos7:20191218
