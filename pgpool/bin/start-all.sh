#!/bin/bash

# docker run --rm -ti --name pgpool -p 5432:5432 \
            # -v "$PWD"/config/pgpool:/config \
            # -v "$PWD"/config/confd:/etc/confd \
            # --entrypoint /bin/bash pgpool/pgpool:4.2.6
# cp ${PGPOOL_CONF_VOLUME}/* ${PGPOOL_INSTALL_DIR}/etc/
# wget https://github.com/kelseyhightower/confd/releases/download/v0.16.0/confd-0.16.0-linux-amd64
# chmod +x confd-0.16.0-linux-amd64
# export PATRONI_NAMESPACE=
# export PATRONI_SCOPE=
# export ETCDCTL_ENDPOINTS=

readonly PATRONI_SCOPE=${PATRONI_SCOPE:-batman}
PATRONI_NAMESPACE=${PATRONI_NAMESPACE:-/service}
# rtrim /
readonly PATRONI_NAMESPACE=${PATRONI_NAMESPACE%/}

CONFD="confd -prefix=$PATRONI_NAMESPACE/$PATRONI_SCOPE -interval=10 -backend"

exec $CONFD etcd -node $(echo $ETCDCTL_ENDPOINTS | sed 's/,/ -node /g')

# Start Pgpool-II
echo "Starting Pgpool-II..."
${PGPOOL_INSTALL_DIR}/bin/pgpool -n \
    -f ${PGPOOL_INSTALL_DIR}/etc/pgpool.conf \
    -F ${PGPOOL_INSTALL_DIR}/etc/pcp.conf
