#!/bin/bash
# set -e

# 启动SSH
sudo /usr/sbin/sshd

# 设置环境变量
# 如果不source，后续的指令将无法执行
source /home/gpadmin/.bashrc
which gpstart

# 启动GPDB
if [ `hostname` == "mdw" ];then
    echo "NODE is: `hostname`"
    if [ ! -d $MASTER_DATA_DIRECTORY ];then
        echo 'Master directory does not exist. Initializing master from gpinitsystem_reflect'
        gpssh-exkeys -f config/hostlist
        echo "Key exchange complete"
        gpinitsystem -a -c config/gpinitsystem_config
        # 假设主机为两台，每个搭载两个segment，执行初始化命令gpinitsystem
        # 加上–S也无法启用spread mirror模式，并且还会报错
        # gpinitsystem -a -c config/gpinitsystem_config -S
        echo "Master node initialized"
        # receive connection from anywhere.. This should be changed!!
        echo "host all all 0.0.0.0/0 trust" >> $MASTER_DATA_DIRECTORY/pg_hba.conf
        # gpstop -u

        # Limit Pivotal Greenplum Logging Information
        # Ref: https://community.pivotal.io/s/article/How-to-Limit-Pivotal-Greenplum-Logging-Information
        echo -e "Y\n" | gpconfig -c log_min_messages -v fatal
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
        gpstate -b
    fi
else
    echo "NODE is: `hostname`"
fi

# 【推荐手动】启用Standby
# gpinitstandby -s smdw

# 【推荐手动】启动性能数据收集器
# gpperfmon_install --enable --password gpmon --port 5432
# gpstop -r
# 【推荐手动】启动GPCC
CHECK_GPMMON=`ps -ef | grep gpmmon | grep -v grep | wc -l`
if [[ $CHECK_GPMMON -ne 0 && -f /home/gpadmin/.pgpass ]]; then
    echo "Install GPCC..."
    # Ref:http://gpcc.docs.pivotal.io/450/topics/install.html
    # unzip greenplum-cc-web-4.5.1-LINUX-x86_64.zip
    # ./greenplum-cc-web-4.5.1-LINUX-x86_64/gpccinstall-4.5.1 -c config/gpccinstall_config
    # source /usr/local/greenplum-cc-web/gpcc_path.sh
    # gpcc start
    # echo "source /usr/local/greenplum-cc-web/gpcc_path.sh" >> /home/gpadmin/.bashrc
fi

# 用于维持容器抓状态的死循环
while true; do echo 'Greenplum is running'; sleep 600; done