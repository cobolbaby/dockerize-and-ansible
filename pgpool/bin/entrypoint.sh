#!/bin/bash

readonly PATRONI_SCOPE=${PATRONI_SCOPE:-batman}
PATRONI_NAMESPACE=${PATRONI_NAMESPACE:-/service}
# rtrim /
readonly PATRONI_NAMESPACE=${PATRONI_NAMESPACE%/}
readonly PGPOOL_HEALTH_CHECK_USER=${PGPOOL_HEALTH_CHECK_USER:-nobody}
readonly PGPOOL_HEALTH_CHECK_PASSWORD=${PGPOOL_HEALTH_CHECK_PASSWORD:-}

# Dynamic configuration 
sed -i "s/^#*\s*health_check_user\s*=.*/health_check_user = '${PGPOOL_HEALTH_CHECK_USER}'/" /etc/confd/templates/pgpool.tmpl
sed -i "s/^#*\s*health_check_password\s*=.*/health_check_password = '${PGPOOL_HEALTH_CHECK_PASSWORD}'/" /etc/confd/templates/pgpool.tmpl

# Start Confd
CONFD="confd -prefix=$PATRONI_NAMESPACE/$PATRONI_SCOPE -interval=10 -backend"

$CONFD etcd -node $(echo $ETCDCTL_ENDPOINTS | sed 's/,/ -node /g') -onetime -sync-only

# Start Pgpool-II
${PGPOOL_INSTALL_DIR}/bin/pgpool \
    -f ${PGPOOL_INSTALL_DIR}/etc/pgpool.conf \
    -F ${PGPOOL_INSTALL_DIR}/etc/pcp.conf

$CONFD etcd -node $(echo $ETCDCTL_ENDPOINTS | sed 's/,/ -node /g')
