#!/bin/bash
set -e
cd `dirname $0`

schema="ict"
table="ictlogtestpart_ao"

# 针对 pg10 版本，动态条件会造成全表扫描，除非拼接 动态SQL
# where="testtime < '`date "+%Y-%m-%d %H:%M:%S"`'::timestamp - interval '7 day'"
where="testtime < '`date "+%Y-%m-%d 00:00:00"`'::timestamp - interval '7 day'"
# 而针对 pg11 / pg12 版本，动态条件应该做了优化，支持了分区裁剪
# where="testtime < now() - interval '7 day'"

echo $where

export PGHOST=
export PGPORT=
export PGUSER=
export PGPASSWORD=
export PGDATABASE=

psql -At -c "explain (FORMAT JSON) select * from ${schema}.${table} where ${where}" > ../test/pg10-plan.json

partitions=`cat ../test/pg10-plan.json | jq '.[0].Plan.Plans[] | ."Relation Name"' | tr -d "\""`

for part_tbl in $partitions
do
    echo ${schema}.$part_tbl

    # Alter tablespace
    # 无需关心导出的数据格式，只是换了一块盘，依赖文件系统，不能是S3

    # Or dump table and migrate to S3
    # 导出的数据格式需要符合外部表所兼容的格式，另外结存过程中可能还要落一次盘(尽量避免)
    # 迁移到S3的数据，可以采用外部表的形式挂载
    
    # 所以:
    # 如果最终存储在某块磁盘，推荐是用 tablespace 的方式
    # 如果最终存储在S3，就是后面的实现

done