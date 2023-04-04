#! /bin/bash
cd `dirname $0`

VERSION=8.3.3.1

# wget https://github.com/grafana/grafana/archive/refs/tags/v8.3.3.zip
# unzip v8.3.3.zip
# cd grafana-8.3.3
# git apply ../patch/*.patch
# make build-docker-full
docker tag grafana/grafana:dev grafana/grafana:${VERSION}

docker build --rm -f Dockerfile \
            -t registry.inventec/infra/grafana/grafana:${VERSION}-plus \
            --build-arg VERSION=${VERSION} \
            .
