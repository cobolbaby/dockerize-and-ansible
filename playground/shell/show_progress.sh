#!/bin/bash

# 获取当前时间戳（毫秒）
getCurrentTimeMillis() {
    echo $(date +%s%3N)
}

# 对小数四舍五入
round() {
    printf "%.0f" $1
}

# 根据传入的完成比显示进度条
showProgress() {
    percentComplete=$1
    # 进度条长度
    barlen=$(tput cols|awk '{print $1-22}')
    # 已完成部分的长度
    completed=$(round $(echo "$barlen*$percentComplete"|bc))
    equals=$(printf "%0.s=" $(seq 1 $completed))
    equals=$(echo $equals|sed 's/=$/>/')
    
    spaces=""
    if [ $completed -lt $barlen ];then
        # 未完成部分的长度
        incomplete=$(($barlen - $completed))
        if [ $completed -eq 0 ];then
            let incomplete--
        fi
        spaces=$(printf "%0.s " $(seq 1 $incomplete))
    fi
    
    # 将完成比转换成百分数
    percentage=$(round $(echo "$percentComplete*100"|bc))
    # 计算耗时
    elapsed=$(echo "scale=1; ($(getCurrentTimeMillis)-${startTimeMillis})/1000"|bc)
    # 打印进度等信息
    printf "\r进度 %4d%%[%s%s] in %0.1fs" $percentage $equals "$spaces" $elapsed
    if [ "$percentage" == "100" ];then
        echo
    fi
}

# 总任务数
total=30
# 当前完成的任务数
current=0
# 开始时间
startTimeMillis=$(getCurrentTimeMillis)

showProgress 0
while [ $current -lt $total ]; do
    # 模拟任务完成
    ((current++))
    # 计算完成比
    percentComplete=$(echo "scale=2;$current/$total"|bc)
    showProgress $percentComplete
done