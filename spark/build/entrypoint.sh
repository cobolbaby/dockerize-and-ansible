#!/bin/bash
# set -e

# 启动sshd
/usr/sbin/sshd

if [ `hostname` == "sparkmaster" ];then
    echo "NODE is: `hostname`"
    ./sbin/start-all.sh
    # ./sbin/start-master.sh
else
    echo "NODE is: `hostname`"
    # ./sbin/start-slaves.sh spark://sparkmaster:7077
fi

# 临时脚本，用于维持容器抓状态
while true; do echo 'Spark Service is up'; sleep 60; done
# 获取进程状态
