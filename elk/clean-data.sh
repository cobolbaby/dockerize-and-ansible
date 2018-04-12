#! /bin/bash

# 变量定义
INDEX_COLLECTION=./.indices
TIME_AGO=$(date -d "10 days ago" +%s)

echo "======================================================="

# 获取索引信息
#curl 'localhost:9200/_cat/indices?v'
#curl -XPOST 'localhost:9200/<indice_name>/_close'
#curl 'localhost:9200/_cat/indices?v'

for i in "$(curl -s 'localhost:9200/_cat/indices' | awk '{print $3}')"
do
    # 截取出时间字符串，与当前时间进行比较，筛选出3个月之前的索引
    
    # 1)将shujuguan-service-2018.03.31 => 2018.03.31
    indice_date=${i##shujuguan*-}
    # 2)2018.03.31 => 2018-03-31
    indice_date=${indice_date//./-}
    # 3)data -d "2018-03-03" +%s
    indice_timestamp=`date -d $indice_date +%s`
    # 4)compare indice_time to TIME_AGO
    if [ $indice_timestamp -lt $TIME_AGO ]; then
        echo "$i" >> $INDEX_COLLECTION
    fi
done

if [ -f $INDEX_COLLECTION ]; then
    echo `wc -l $INDEX_COLLECTION`
else
    echo '没有满足条件的历史记录'
fi

# 执行删除操作
for i in "$(cat $INDEX_COLLECTION)"
do
    echo $i
done

# 删除临时文件
if [ -f $INDEX_COLLECTION ]; then
    rm $INDEX_COLLECTION
    echo '清除脚本执行过程中生成的临时文件'
fi