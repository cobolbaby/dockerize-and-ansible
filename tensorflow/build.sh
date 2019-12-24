#!/bin/bash
set -e
cd `dirname $0`

REGISTRY=registry.inventec
PROXY=http://10.190.40.39:12306/

docker build --rm -f Dockerfile -t ${REGISTRY}/development/tensorflow:1.13.1-gpu-py3-jupyter --build-arg http_proxy=${PROXY} --build-arg https_proxy=${PROXY} .

