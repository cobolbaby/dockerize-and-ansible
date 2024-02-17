#!/bin/bash
set -e
# fix: pg copy 失败之后，仍执行了后面的 drop 操作
# ref: https://www.jianshu.com/p/c24ac0e4d147
set -o pipefail
cd `dirname $0`

prerequisites=("psql")

# 判断是否存在必要的命令
for cmd in ${prerequisites[@]}; do
    if ! command -v $cmd &> /dev/null
    then
        printf "You don\'t seem to install %s.\n" $cmd
        exit 1
    fi
done

source .env

# 首先获取需要归档的表，然后循环执行 psql 對拷

psql_cmd="psql -Atc"


# 获取全部的分区表
partition_tables=()

for partition_table in ${partition_tables[@]}; do
    # 获取表名和Schema名
    # Ref: https://www.delftstack.com/howto/linux/split-string-into-array-in-bash/
    t=(`echo $partition_table | tr '.' ' '`)

    relname=${t[1]}
    nspname=${t[0]}
    echo "Archive relname: $relname, nspname: $nspname"
    
    . ./setvars.sh
    # echo "pg_get_retention_partitions: $pg_get_retention_partitions"

    # 获取过期分区，归档并删除
    retention_partitions=`$psql_cmd """${pg_get_retention_partitions}"""`
    
    for part in $retention_partitions; do
        echo "Archive partition: $part"
        # pg_dump -Fc -t $part > $archive_path/$part.dump

        echo "Sync dump to GP"
        psql -c "COPY ${part} TO STDOUT" | \
        psql -h ${GPHOST} -p ${GPPORT} -d ${GPDATABASE} -U ${GPUSER} \
             -c "COPY ${partition_table} FROM STDIN"

        echo "Drop partition: $part"
        $psql_cmd "DROP TABLE IF EXISTS $part"
    done

    
done

# 获取全部的分区表
partition_tables=(dw.fact_yield_unit ict.ict_component_log)

for partition_table in ${partition_tables[@]}; do
    # 获取表名和Schema名
    # Ref: https://www.delftstack.com/howto/linux/split-string-into-array-in-bash/
    t=(`echo $partition_table | tr '.' ' '`)

    relname=${t[1]}
    nspname=${t[0]}
    echo "Archive relname: $relname, nspname: $nspname"
    
    . ./setvars.sh
    # echo "pg_get_expired_partitions: $pg_get_expired_partitions"

    # 获取过期分区，归档并删除
    expired_partitions=`$psql_cmd """${pg_get_expired_partitions}"""`
    
    for part in $expired_partitions; do
        echo "Archive partition: $part"
        # pg_dump -Fc -t $part > $archive_path/$part.dump

        echo "Sync dump to GP"
        PGOPTIONS="-c idle_in_transaction_session_timeout=1h -c statement_timeout=1h" \
        psql -c "COPY ${part} TO STDOUT" | \
        PGOPTIONS="-c statement_timeout=1h" \
        psql -h ${GPHOST} -p ${GPPORT} -d ${GPDATABASE} -U ${GPUSER} \
             -c "COPY ${partition_table} FROM STDIN"

        echo "Drop partition: $part"
        $psql_cmd "DROP TABLE IF EXISTS $part"
    done

    
done