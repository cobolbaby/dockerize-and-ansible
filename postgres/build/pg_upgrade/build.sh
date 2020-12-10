#!/bin/bash
set -e
cd `dirname $0`

PROXY=http://10.190.40.39:2379/
OLD_VERSION=10
NEW_VERSION=12

docker build --rm -f Dockerfile \
            -t registry.inventec/infra/pg_upgrade:${OLD_VERSION}-to-${NEW_VERSION} \
            --build-arg http_proxy=${PROXY} \
            --build-arg https_proxy=${PROXY} \
            --build-arg OLD_VERSION=${OLD_VERSION} \
            --build-arg PG_MAJOR=${NEW_VERSION} \
            .
docker push registry.inventec/infra/pg_upgrade:${OLD_VERSION}-to-${NEW_VERSION}
