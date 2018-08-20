#!/bin/bash
# 启动sshd
sudo /usr/sbin/sshd

if [ `hostname` == "mdw" ];then
    echo "NODE is: `hostname`"
    if [ ! -d $MASTER_DATA_DIRECTORY ];then
        echo 'Master directory does not exist. Initializing master from gpinitsystem_reflect'
        gpssh-exkeys -f config/hostlist
        echo "Key exchange complete"
        gpinitsystem -a -c config/gpinitsystem_config
        echo "Master node initialized"
        # receive connection from anywhere.. This should be changed!!
        echo "host all all 0.0.0.0/0 md5" >> $MASTER_DATA_DIRECTORY/pg_hba.conf
        gpstop -u
    else
        echo 'Master exists. Restarting gpdb'
        gpstart -a
    fi
else
    echo "NODE is: `hostname`"
fi

# 临时脚本，用于维持容器抓状态
while true; do echo 'Greenplum is running'; sleep 60; done
# 获取进程状态
