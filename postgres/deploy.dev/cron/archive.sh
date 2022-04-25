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
mkdir -p ${archive_path} && cd ${archive_path}
echo "【`date`】Create archive directory: $(pwd)"

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

    # 获取过期分区，归档并删除
    pg_get_expired_partitions=$(cat <<-EOF
        WITH q_expired_part AS (
            select
                *,
                ((regexp_match(part_expr, \$$ TO \('(.*)'\)\$$))[1])::timestamp without time zone as part_end
            from
                (
                    select
                        format('%I.%I', n.nspname, p.relname) as parent_name,
                        format('%I.%I', n.nspname, c.relname) as part_name,
                        pg_catalog.pg_get_expr(c.relpartbound, c.oid) as part_expr
                    from
                        pg_class p
                        join pg_inherits i ON i.inhparent = p.oid
                        join pg_class c on c.oid = i.inhrelid
                        join pg_namespace n on n.oid = c.relnamespace
                    where
                        p.relname = '${relname}'
                        and n.nspname = '${nspname}'
                        and p.relkind = 'p'
                ) x
        )
        SELECT
            -- format('DROP TABLE IF EXISTS %s', part_name) as sql_to_exec
            part_name
        FROM
            q_expired_part
        WHERE
            part_end < CURRENT_DATE - '6 month'::interval
            and part_name !~* '(his|default|extra)$';
EOF
)
    
    echo "Archive relname: $relname, nspname: $nspname"
    # echo "pg_get_expired_partitions: $pg_get_expired_partitions"

    expired_partitions=`$psql_cmd """${pg_get_expired_partitions}"""`
    
    for part in $expired_partitions
    do
        echo "Archive partition: $part"
        pg_dump -Fc -t $part > $archive_path/$part.dump

        # echo "Sync dump to S3"
        # scp -P $port -i $ssh_key_path $archive_path/$part.dump $ssh_user@$host:$pg_data_path/$part.dump 

        echo "Drop partition: $part"
        # $psql_cmd "DROP TABLE IF EXISTS $part"
    done

    # 新建分区
    pg_get_new_partitions=$(cat <<-EOF
        WITH q_last_part AS (
            select
                *,
                ((regexp_match(part_expr, \$$ TO \('(.*)'\)\$$))[1])::timestamp without time zone as last_part_end
            from
                (
                    select
                        format('%I.%I', n.nspname, p.relname) as parent_name,
                        format('%I.%I', n.nspname, c.relname) as part_name,
                        pg_catalog.pg_get_expr(c.relpartbound, c.oid) as part_expr
                    from
                        pg_class p
                        join pg_inherits i ON i.inhparent = p.oid
                        join pg_class c on c.oid = i.inhrelid
                        join pg_namespace n on n.oid = c.relnamespace
                    where
                        p.relname = '${relname}'
                        and n.nspname = '${nspname}'
                        and p.relkind = 'p'
                        and c.relname !~* '(his|default|extra)$'
                ) x
            order by
                last_part_end desc
            limit
                1
        )
        SELECT
            parent_name,
            extract(year from last_part_end) as year,
            lpad((extract(month from last_part_end))::text, 2, '0') as month,
            last_part_end,
            last_part_end + '1 month' :: interval as next_part_end,
            format(
                \$$ CREATE TABLE IF NOT EXISTS %s_%s%s PARTITION OF %s FOR VALUES FROM ('%s') TO ('%s') \$$,
                parent_name,
                extract(year from last_part_end),
                lpad((extract(month from last_part_end))::text, 2, '0'),
                -- lpad((extract(day from last_part_end))::text, 2, '0'),
                parent_name,
                last_part_end,
                last_part_end + '1 month' :: interval
            ) AS sql_to_exec
        FROM
            q_last_part;
EOF
)
    # echo "pg_get_new_partitions: $pg_get_new_partitions"
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
    
