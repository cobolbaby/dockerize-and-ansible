#!/bin/bash
set -e
cd `dirname $0`

PGPOOL_VERSION=4.3.1

docker build --rm -f Dockerfile \
            -t registry.inventec/infra/pgpool:${PGPOOL_VERSION} \
            --build-arg PGPOOL_VERSION=${PGPOOL_VERSION} \
            .