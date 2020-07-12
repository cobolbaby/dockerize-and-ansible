#! /bin/bash
cd `dirname $0`

PROXY=http://10.190.40.39:2379/
VERSION=12.10.8-ce.0

diff -urNa ${VERSION} ${VERSION}-fixed > patch/gitlab-${VERSION}.patch

docker build --rm -f Dockerfile \
            -t registry.inventec/development/gitlab/gitlab-ce:${VERSION} \
            --build-arg http_proxy=${PROXY} \
            --build-arg https_proxy=${PROXY} \
            --build-arg VERSION=${VERSION} \
            .
