#!/bin/bash
# set -e
# set -o pipefail
cd `dirname $0`

source /usr/local/greenplum-db/greenplum_path.sh
export MASTER_DATA_DIRECTORY=/disk1/gpdata/gpmaster/gpseg-1

/usr/local/greenplum-db/bin/gpstate -b
/usr/local/greenplum-db/bin/gpstop -M fast -a
