#!/bin/bash
# set -e
cd `dirname $0`

for i in $(docker ps | grep 'infra/postgres' | awk '{print $1}'); do 
    echo "【`date`】Running db backup job..."
    docker exec $i /pgcron/pg_basebackup.sh
done
