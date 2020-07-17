#!/bin/bash
set -e
cd `dirname $0`

REGISTRY=registry.inventec

docker build --rm -f Dockerfile -t ${REGISTRY}/development/python-36-centos7:latest .
docker push ${REGISTRY}/development/python-36-centos7:latest
