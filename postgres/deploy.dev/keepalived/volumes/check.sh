#!/bin/bash

# Load Env
export PGPORT=5493
export PGUSER=postgres
export PGPASSWORD=******

# 如果是备库,则退出，此脚本不检查备库存活状态
standby_flg=`psql -h 127.0.0.1 -p $PGPORT -U $PGUSER -d postgres -At -c "select pg_is_in_recovery();"`

# 先判断上面的语句是否执行成功？如果没有成功，直接返回2
if [ $? -ne 0 ]; then
    # psql: could not connect to server
    # psql: the database system is starting up
    echo "`date +%F\ %T`: PG has gone away!"
    exit 1
fi

if [ ${standby_flg} == 't' ]; then
    echo -e "`date +%F\ %T`: This is a standby."
    exit 1
fi

exit 0
