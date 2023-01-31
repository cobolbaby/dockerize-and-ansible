#! /bin/bash
cd `dirname $0`

PROXY=http://10.190.81.209:3389/
VERSION=12.10.14-ce.0
VERSION=13.12.15-ce.0
VERSION=15.4.4-ce.0
VERSION=15.4.6-ce.0

# diff -urNa ${VERSION} ${VERSION}-fixed > patch/gitlab-${VERSION}.patch

docker build --rm -f Dockerfile \
            -t registry.inventec/infra/gitlab/gitlab-ce:${VERSION} \
            --build-arg http_proxy=${PROXY} \
            --build-arg https_proxy=${PROXY} \
            --build-arg VERSION=${VERSION} \
            .

docker push registry.inventec/infra/gitlab/gitlab-ce:${VERSION}
