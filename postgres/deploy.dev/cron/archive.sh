#!/bin/bash
set -e
cd `dirname $0`

prerequisites=("pg_dump" "psql")

# 判断是否存在必要的命令
for cmd in ${prerequisites[@]}; do
    if ! command -v $cmd &> /dev/null
    then
        printf "You don\'t seem to install %s.\n" $cmd
        exit 1
    fi
done

# *****************************************************************************
# 根据需求，请自行修改
# *****************************************************************************

source .env

archive_local_path=/tmp/hdd/postgres/11
# archive_s3_bucket=infra-backup
# archive_s3_path=/postgres/11

# *****************************************************************************
# *****************************************************************************

archive_subdir=archive/$(date "+%Y%m%d")
archive_path=${archive_local_path}/${archive_subdir}
mkdir -p ${archive_path}
echo "【`date`】Create archive directory: ${archive_path}"

psql_cmd="psql -Atc"

pg_get_partition_tables="SELECT distinct inhparent::regclass FROM pg_inherits"

# 获取全部的分区表
partition_tables=$($psql_cmd """$pg_get_partition_tables""")

for partition_table in $partition_tables; do
    # 获取表名和Schema名
    # Ref: https://www.delftstack.com/howto/linux/split-string-into-array-in-bash/
    t=(`echo $partition_table | tr '.' ' '`)

    relname=${t[1]}
    nspname=${t[0]}
    echo "Archive relname: $relname, nspname: $nspname"
    
    . ./setvars.sh
    # echo "pg_get_expired_partitions: $pg_get_expired_partitions"
    # echo "pg_get_new_partitions: $pg_get_new_partitions"

    # 获取过期分区，归档并删除
    expired_partitions=`$psql_cmd """${pg_get_expired_partitions}"""`
    
    for part in $expired_partitions
    do
        echo "Archive partition: $part"
        pg_dump -Fc -t $part > $archive_path/$part.dump

        # echo "Sync dump to S3"
        # ...

        echo "Drop partition: $part"
        # $psql_cmd "DROP TABLE IF EXISTS $part"
    done

    # 预创建新分区，每次执行创建一个
    new_partitions=`$psql_cmd """${pg_get_new_partitions}"""`
    echo "New partitions: $new_partitions"

    # https://stackoverflow.com/questions/10586153/how-to-split-a-string-into-an-array-in-bash
    IFS='|' read -r -a new_partitions_array <<< "$new_partitions"
    ddl="${new_partitions_array[5]}"

    echo "Create partition: $ddl"
    $psql_cmd """$ddl"""

done

# Or dump table and migrate to S3
#

# Alter tablespace
# 该策略更像是在借助多盘来提升磁盘IO性能

# 所以:
# 如果是为了分担磁盘读写压力，一般采用 tablespace 的方式
# 如果是为了归档保存，则视情况而定，
#   若数据一个月还可能用那么几次，则建议保存为csv格式文件，在Minio层级做压缩
#   若数据只是为了存储，则建议保存的时候就采用压缩保存，且不为其创建外部表
    
