#! /bin/bash

# 变量定义
INDEX_COLLECTION=./indices
TIME_AGO=$(date -d "17 days ago" +%s)

echo "======================================================="

# 获取索引信息
#curl 'localhost:9200/_cat/indices?v'
#curl -XPOST 'localhost:9200/<indice_name>/_close'
#curl 'localhost:9200/_cat/indices?v'

for i in $(curl -s 'localhost:9200/_cat/indices' | awk '{print $3}')
do
    # 截取出时间字符串，与当前时间进行比较，筛选出3个月之前的索引
    # 1)将shujuguan-service-2018.03.31 => 2018.03.31
    indice_date=${i##shujuguan*-}
    # 2)2018.03.31 => 2018-03-31
    indice_date=${indice_date//./-}

    # 过滤无关项，非时间
    if [ "$i" == ".kibana" ]; then
        continue
    fi

    # 3)data -d "2018-03-03" +%s
    indice_timestamp=$(date -d $indice_date +%s)
    # 4)compare indice_time to TIME_AGO
    if [ $indice_timestamp -lt $TIME_AGO ]; then
        echo $i
        echo "$i" >> $INDEX_COLLECTION
    fi
done

if [ ! -f $INDEX_COLLECTION ]; then
    echo '没有满足条件的历史记录'
    exit
fi

echo `wc -l $INDEX_COLLECTION`

# 执行删除操作
for i in `cat $INDEX_COLLECTION`
do
    uri=localhost:9200/$i?pretty
    echo delete $i
    curl -XDELETE $uri
    sleep 3s
done

# 删除临时文件
rm $INDEX_COLLECTION
echo '清除脚本执行过程中生成的临时文件'