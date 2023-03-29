#!/bin/bash
set -e
# set -o pipefail
cd `dirname $0`

source .env

archive_s3_bucket=${MC_BUCKET:-infra-backup}
archive_s3_path=postgresql
archive_subdir=$(date +%Y%m%d%H%M%S)

echo "【`date`】Start to pg_dump DB..."

# user, tablespace
echo "【`date`】Dump global information, including users and tablespaces:"
time pg_dumpall --globals-only | mc pipe backup/${archive_s3_bucket}/${archive_s3_path}/${PGHOST}/${archive_subdir}/pg_globals.sql

# schema, table, function, data
for db in $(psql postgres -Atc 'select datname from pg_database;' | grep -vE 'postgres|template|_del$|bdc')
do 
    echo "【`date`】Dump DB ${db}:"
	time pg_dump -Fc ${db} | mc pipe backup/${archive_s3_bucket}/${archive_s3_path}/${PGHOST}/${archive_subdir}/${db}.dump
done

# schema, table, function
for db in $(psql postgres -Atc 'select datname from pg_database;' | grep -E 'bdc')
do
    echo "【`date`】Dump DB ${db}:"
	time pg_dump -s ${db} | mc pipe backup/${archive_s3_bucket}/${archive_s3_path}/${PGHOST}/${archive_subdir}/${db}.sql
done

echo "【`date`】pg_dump DB end."

exit 0
