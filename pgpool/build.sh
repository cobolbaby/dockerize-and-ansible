#!/bin/bash
set -e
cd `dirname $0`

PGPOOL_VER=4.3.6

# git clone https://github.com/pgpool/pgpool2_on_k8s.git
cd pgpool2_on_k8s/pgpool.docker
docker build --rm -f Dockerfile.pgpool \
            -t pgpool/pgpool:${PGPOOL_VER} \
            --build-arg PGPOOL_VER=${PGPOOL_VER} \
            .

cd -

cd build
docker build --rm -f Dockerfile \
            -t registry.inventec/infra/pgpool:${PGPOOL_VER} \
            --build-arg PGPOOL_VER=${PGPOOL_VER} \
            .

docker push registry.inventec/infra/pgpool:${PGPOOL_VER}
