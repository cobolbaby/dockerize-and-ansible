#!/bin/bash
# set -e
cd `dirname $0`

# *****************************************************************************
# *****************************************************************************
database="bdc"
schema="ict"
table="ictlogtestpart_ao"
archive_local_path=/tmp/hdd/postgres/10
archive_s3_path=/postgres/10
archive_s3_bucket=prod-picture

source .env
# *****************************************************************************
# *****************************************************************************

archive_subdir=archive/$(date "+%Y%m%d")

archive_path=${archive_local_path}/${archive_subdir}
mkdir -p ${archive_path} && cd ${archive_path}
echo "【`date`】Archive path: $(pwd)"

echo "【`date`】SQL query table: ${schema}.${table}"

# 针对 pg10 版本，动态条件会造成全表扫描，除非拼接 动态SQL
# where="testtime < '$(date "+%Y-%m-%d 00:00:00")'::timestamp - interval '7 day'"
# 而针对 pg11 / pg12 版本，动态条件应该做了优化，支持了分区裁剪
where="testtime < now() - interval '7 day'"
echo "【`date`】SQL query condition: $where"

temp_plan=sql-plan-$(date "+%Y%m%d%H%M%S").json
echo "【`date`】SQL execution plan: $temp_plan"

psql -At -d $database -c "explain (FORMAT JSON) select * from ${schema}.${table} where ${where}" > $temp_plan

partitions=`cat $temp_plan | jq '.[0].Plan.Plans[] | ."Relation Name"' | tr -d "\""`

# 如果配置了转存S3，需要执行如下命令
# mc config host add minio <URL> <AccessKey> <SecretKey>

for part_tbl in $partitions
do
    echo "【`date`】Archive table: ${schema}.${part_tbl}"
    
    # 最简单的就是dump出来，调用pg_dump的命令，然后可选择是否保存在S3上
    command="pg_dump -Fc $database -t ${schema}.${part_tbl} > $archive_path/${schema}.${part_tbl}.dump"
    echo "【`date`】Archive command: $command"
    eval $command
    # 如果配置了转存S3，需要执行如下命令
    # mc cp --recursive ${archive_path}/${schema}.${part_tbl}.dump minio/${archive_s3_bucket}/${archive_s3_path}/${archive_subdir}/
    # 归档之后删除
    # 判断是否为默认分区，如果是默认分区，则采用delete的命令，如果是其他历史分区，则直接drop
    # psql -At -d $database -c "drop table ${schema}.${part_tbl}"
    if [[ $part_tbl =~ _default$ ]] 
    then
        echo "delete from ${schema}.${part_tbl} where ${where}"
    else
        echo "drop from ${schema}.${part_tbl}"
    fi

    # Alter tablespace
    # 无需关心导出的数据格式，只是换了一块盘，依赖文件系统，不能是S3
    
    # Or dump table and migrate to S3
    # 导出的数据格式需要符合外部表所兼容的格式，另外结存过程中可能还要落一次盘(尽量避免)
    # 迁移到S3的数据，可以采用外部表的形式挂载
    

    # 所以:
    # 如果最终存储在某块磁盘，推荐是用 tablespace 的方式
    # 如果最终存储在S3，就是后面的实现
    
done

