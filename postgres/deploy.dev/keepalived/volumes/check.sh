#!/bin/bash

# Load Env
export PGPORT=5493
export PGUSER=postgres
export PGPASSWORD=postgres

# 如果是备库,则退出，此脚本不检查备库存活状态
standby_flg=`psql -h 127.0.0.1 -p $PGPORT -U $PGUSER -d postgres -At -c "select pg_is_in_recovery();"`
if [ ${standby_flg} == 't' ]; then
    echo -e "`date +%F\ %T`: This is a standby database, exit!\n"
    exit 1
fi

exit 0
