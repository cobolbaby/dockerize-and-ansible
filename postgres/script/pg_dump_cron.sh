#!/bin/bash
set -e
cd `dirname $0`

# echo "【`date`】Getting the container ID of Postgres"
# CONTAINERID=`docker ps --filter name=pg --format "{{.ID}}"`

echo "【`date`】Running db backup job..."
# docker exec ${CONTAINERID} /pgcron/pg_dump.sh

source .env
./pg_dump.sh
