#!/bin/bash

PATRONI_NAMESPACE=${PATRONI_NAMESPACE:-/service}
# rtrim /
readonly PATRONI_NAMESPACE=${PATRONI_NAMESPACE%/}
readonly PATRONI_SCOPE=${PATRONI_SCOPE:-batman}
readonly CONFD_BACKEND=${CONFD_BACKEND:-etcd}
readonly PGPOOL_HEALTH_CHECK_USER=${PGPOOL_HEALTH_CHECK_USER:-nobody}
readonly PGPOOL_HEALTH_CHECK_PASSWORD=${PGPOOL_HEALTH_CHECK_PASSWORD:-}
readonly PGPOOL_PORT=${PGPOOL_PORT:-5432}
readonly PGPOOL_NUM_INIT_CHILDREN=${PGPOOL_NUM_INIT_CHILDREN:-200}

# Dynamic configuration 
sed -i "s/^#*\s*sr_check_user\s*=.*/sr_check_user = '${PGPOOL_HEALTH_CHECK_USER}'/" /etc/confd/templates/pgpool.tmpl
sed -i "s/^#*\s*health_check_user\s*=.*/health_check_user = '${PGPOOL_HEALTH_CHECK_USER}'/" /etc/confd/templates/pgpool.tmpl
sed -i "s/^#*\s*port\s*=.*/port = ${PGPOOL_PORT}/" /etc/confd/templates/pgpool.tmpl
sed -i "s/^#*\s*num_init_children\s*=.*/num_init_children = ${PGPOOL_NUM_INIT_CHILDREN}/" /etc/confd/templates/pgpool.tmpl
echo "${PGPOOL_HEALTH_CHECK_USER}:TEXT${PGPOOL_HEALTH_CHECK_PASSWORD}" > ${PGPOOL_INSTALL_DIR}/etc/pool_passwd

# Start Confd
CONFD="confd -prefix=${PATRONI_NAMESPACE}/${PATRONI_SCOPE} -interval=10"

$CONFD -backend $CONFD_BACKEND -node $(echo $ETCDCTL_ENDPOINTS | sed 's/,/ -node /g') -onetime -sync-only

# Start Pgpool-II
${PGPOOL_INSTALL_DIR}/bin/pgpool \
    -f ${PGPOOL_INSTALL_DIR}/etc/pgpool.conf \
    -F ${PGPOOL_INSTALL_DIR}/etc/pcp.conf

$CONFD -backend $CONFD_BACKEND -node $(echo $ETCDCTL_ENDPOINTS | sed 's/,/ -node /g')
