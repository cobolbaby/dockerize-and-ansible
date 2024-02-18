#!/bin/bash
set -e
cd `dirname $0`

PROXY=http://10.190.81.209:3389/
OLD_VERSION=12
NEW_VERSION=16.2

docker build --rm -f Dockerfile \
            -t registry.inventec/infra/pg_upgrade:${OLD_VERSION}-to-${NEW_VERSION} \
            --build-arg http_proxy=${PROXY} \
            --build-arg https_proxy=${PROXY} \
            --build-arg OLD_VERSION=${OLD_VERSION} \
            --build-arg NEW_VERSION=${NEW_VERSION} \
            .
docker push registry.inventec/infra/pg_upgrade:${OLD_VERSION}-to-${NEW_VERSION}
