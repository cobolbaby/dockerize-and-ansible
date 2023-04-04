#!/bin/sh
cd `dirname $0`

# apt update
# apt install -y wget perl make libtext-csv-perl
# wget --no-check-certificate -O pgbadger-11.7.tar.gz https://github.com/darold/pgbadger/archive/refs/tags/v11.7.tar.gz
# tar -xzf pgbadger-11.7.tar.gz
# cd pgbadger-11.7/
# perl Makefile.PL
# make && make install

pgbadger --exclude-query="^(Query Text|COPY|COMMIT)" -f csv $PGDATA/log/postgresql-*.csv
