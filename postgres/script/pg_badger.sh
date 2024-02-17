#!/bin/bash
cd `dirname $0`

if [ -z $1 ]; then
    echo 'No logs specified, please check the script parameters.'
    # echo 'Usage: '$0' postgresql-2023-06-26_*.csv'
    echo 'Usage: '$0' 2023-06-26'
    exit
fi

pgrole=$(curl -s http://localhost:8008/patroni | jq .role | sed "s/\"//g")
if [ $pgrole != "master" ]; then
    echo "The role of ${PATRONI_NAME} database is standy."
    exit
fi

# 通过 EXTRA_OPTS 支持更多配置参数，如 '-d dwf_tpms -b "2023-06-27 00:00:00" -e "2023-06-27 03:00:00"'

# pgbadger --exclude-query="^(Query Text|COPY|COMMIT)" -o /tmp/report.html -t 30 ${EXTRA_OPTS} ${PGDATA}/log/postgresql-${1}*.csv

# EXTRA_OPTS='-d dwf_tpms -b "2023-06-27 00:00:00" -e "2023-06-27 03:00:00"' ./pg_badger_test.sh 2023-06-27
# FATAL: logfile "00:00:00"" must exist!
#     - Error at line 2513

# 不加双引号报错

# pgbadger --exclude-query="^(Query Text|COPY|COMMIT)" -o /tmp/report.html -t 30 "${EXTRA_OPTS}" ${PGDATA}/log/postgresql-${1}*.csv

# EXTRA_OPTS='-d dwf_tpms -b "2023-06-27 00:00:00" -e "2023-06-27 03:00:00"' ./pg_badger_test.sh 2023-06-27
# [========================>] Parsed 83024105 bytes of 83024105 (100.00%), queries: 0, events: 0

# 加了双引号，就筛选不出日志，和直接将 "${EXTRA_OPTS}" 替换为 '-d dwf_tpms -b "2023-06-27 00:00:00" -e "2023-06-27 03:00:00"' 一个效果

# pgbadger --exclude-query="^(Query Text|COPY|COMMIT)" -o /tmp/report.html -t 30 -d dwf_tpms -b "2023-06-27 00:00:00" -e "2023-06-27 03:00:00" ${PGDATA}/log/postgresql-${1}*.csv

# ./pg_badger_test.sh 2023-06-27
# [====================>    ] Parsed 71469452 bytes of 83024105 (86.08%), queries: 2364, events: 120
# LOG: Ok, generating html report...

# 直接替换变量，结果没毛病，那到底是哪的问题

# 经过很多次拼接测试，试验出下面的写法：

# 通过 EXTRA_OPTS 支持更多配置参数，如 '-d dwf_tpms -b "2023-06-27 00:00:00" -e "2023-06-27 03:00:00"'
cmd_pgbadger="pgbadger --exclude-query=\"^(Query Text|COPY|COMMIT)\" -o /tmp/report.html -t 30 -f csv ${EXTRA_OPTS} ${PGDATA}/log/postgresql-${1}*.csv"
echo $cmd_pgbadger
eval $cmd_pgbadger

tar -zcvf /tmp/postgresql-${1}.csv.tgz ${PGDATA}/log/postgresql-${1}*.csv

source .env
# export MC_HOST_public=http://public:publicpublic@infra-oss.ipt.inventec.net
# export PGHOST=192.168.2.143

archive_s3_bucket=public
archive_s3_path=postgresql
archive_subdir=$1

mc cp /tmp/report.html public/${archive_s3_bucket}/${archive_s3_path}/${PGHOST}/${archive_subdir}/
mc cp /tmp/postgresql-${1}.csv.tgz public/${archive_s3_bucket}/${archive_s3_path}/${PGHOST}/${archive_subdir}/
mc mv /tmp/report.html public/${archive_s3_bucket}/${archive_s3_path}/${PGHOST}/latest/
mc mv /tmp/postgresql-${1}.csv.tgz public/${archive_s3_bucket}/${archive_s3_path}/${PGHOST}/latest/postgresql.csv.tgz
