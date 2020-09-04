#!/bin/bash
set -e
cd `dirname $0`

REGISTRY=registry.inventec

docker build --rm -f Dockerfile -t ${REGISTRY}/development/tensorflow:1.13.1-gpu-py3-jupyter .
