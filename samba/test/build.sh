#!/bin/bash
set -e
cd `dirname $0`

REGISTRY=registry.inventec

docker build --rm -f Dockerfile -t ${REGISTRY}/development/samba-test:latest .
docker push ${REGISTRY}/development/samba-test:latest
