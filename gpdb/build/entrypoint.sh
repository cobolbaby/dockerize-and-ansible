#!/bin/bash
# set -e

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
        echo "host all all 0.0.0.0/0 trust" >> $MASTER_DATA_DIRECTORY/pg_hba.conf
        # Restart Later
        # gpstop -u

        # Limit Pivotal Greenplum Logging Information
        # Ref: https://community.pivotal.io/s/article/How-to-Limit-Pivotal-Greenplum-Logging-Information
        echo -e "Y\n" | gpconfig -c log_min_messages -v warning
        echo -e "Y\n" | gpconfig -c log_statement -v none
        # gpstop -u

        # Ps: 修改配置需要处于服务启动的情况下
        # [fix] too many clients already
        # change the client max connections and reload the configuration
        # The value on the segments must be greater than the value on the master. 
        # The recommended value of max_connections on segments is 5-10 times the value on the master.
        echo -e "Y\n" | gpconfig -c max_connections -v 5000 -m 1000
        # [fix] the limit of distributed transactions has been reached
        # max_prepared_transactions max_val: 1000 
        echo -e "Y\n" | gpconfig -c max_prepared_transactions -v 1000 -m 1000
        # [ERROR]:-gpstop error: Active connections. Aborting shutdown...
        # gpstop -r
        gpstop -M fast -a
        gpstart -a
        gpconfig -s max_connections
        gpconfig -s max_prepared_transactions
    else
        echo 'Master exists. Restarting gpdb'
        gpssh-exkeys -f config/hostlist
        echo "Key exchange complete"
        gpstart -a
    fi
else
    echo "NODE is: `hostname`"
fi

# 临时脚本，用于维持容器抓状态
while true; do echo 'Greenplum is running'; sleep 60; done
# 获取进程状态
