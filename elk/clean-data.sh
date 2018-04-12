#! /bin/bash

# 变量定义
INDEX_COLLECTION=index.txt
TIME_AGO = $(date -d "90 days ago" +%s)

# 删除历史数据
# rm $INDEX_COLLECTION

echo "======================================================="

# 获取索引信息
#curl 'localhost:9200/_cat/indices?v'
#curl -XPOST 'localhost:9200/<indice_name>/_close'
#curl 'localhost:9200/_cat/indices?v'

for i in "$(curl -s 'localhost:9200/_cat/indices' | awk '{print $3}')"
do
    # 截取出时间字符串，与当前时间进行比较，筛选出3个月之前的索引
    
    # 1)将shujuguan-service-2018.03.31 => 2018.03.31
    # 2)2018.03.31 => 2018-03-31
    # 3)data -d "2018-03-03" +%s
    # 4)compare indice_time to TIME_AGO

    # if [ "$indice_time" < "$TIME_AGO" ] then
        echo "$i" >> $INDEX_COLLECTION
    # fi
done

echo `cat $INDEX_COLLECTION | wc -l` indices

# 执行删除操作