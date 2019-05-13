#!/bin/bash
# set -e

# 启动SSH
sudo /usr/sbin/sshd

# 启动cgroups服务
# Ref: https://pvtl.force.com/s/article/FATAL--cgroup-Is-Not-Properly-Configured-Gives-The-Error-can-not-find-cgroup-mount-point
sudo cgconfigparser -l /etc/cgconfig.d/gpdb.conf 
# Identify the cgroup directory mount point for the node
grep cgroup /proc/mounts
# Verify that you set up the Greenplum Database cgroups configuration correctly by running the following commands. 
# Replace <cgroup_mount_point> with the mount point that you identified in the previous step
ls -l /sys/fs/cgroup/cpu/gpdb
ls -l /sys/fs/cgroup/cpuacct/gpdb

# [fix] Variables in "/etc/sysctl.conf" not work
# [fix] OCI runtime create failed: sysctl "vm.overcommit_memory " is not in a separate kernel namespace: unknown
# [fix] Command "sysctl -w vm.overcommit_ratio=95" execute failed: bash: fork: Cannot allocate memory
# sudo sysctl -p

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
        if [ "$MIRROR_STRATEGY" == "Spread" ]; then
            # 假设segment主机为两台，节点数为2，执行初始化命令gpinitsystem
            # 加上–S也无法启用spread mirror模式，并且还会报错
            gpinitsystem -a -c config/gpinitsystem_config -S
        else
            gpinitsystem -a -c config/gpinitsystem_config
        fi
        echo "Master node initialized"
        # receive connection from anywhere.. This should be changed!!
        echo "host all gpadmin 0.0.0.0/0 trust" >> $MASTER_DATA_DIRECTORY/pg_hba.conf
        # gpstop -u

        # Limit Pivotal Greenplum Logging Information
        # Ref: https://community.pivotal.io/s/article/How-to-Limit-Pivotal-Greenplum-Logging-Information
        gpconfig -c log_min_messages -v fatal
        gpconfig -c log_statement -v none
        # gpstop -u

        # Ps: 修改配置需要处于服务启动的情况下
        # [fix] too many clients already
        # change the client max connections and reload the configuration
        # The value on the segments must be greater than the value on the master. 
        # The recommended value of max_connections on segments is 5-10 times the value on the master.
        gpconfig -c max_connections -v 5000 -m 1000
        # [fix] the limit of distributed transactions has been reached
        # max_prepared_transactions max_val: 1000 
        gpconfig -c max_prepared_transactions -v 1000 -m 1000
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
        # [fix] ExecutionError: 'non-zero rc: 1' occured.  Details: 'ssh -o StrictHostKeyChecking=no -o ServerAliveInterval=60 sdw4 ". /usr/local/greenplum-db/./greenplum_path.sh; $GPHOME/sbin/gpoperation.py"'  cmd had rc=1 completed=True halted=False
        # OSError: [Errno 17] File exists: '/home/gpadmin/gpAdminLogs'
        # Deploy again...
        gpstart -a
    fi
else
    echo "NODE is: `hostname`"
fi

# 【推荐手动】启用Standby
# gpinitstandby -s smdw

# 【推荐手动】启动性能数据收集器
# gpperfmon_install --enable --password gpmon --port 5432
# gpstop -r

# 【无奈手动】启动GPCC
CHECK_GPMMON=`ps -ef | grep gpmmon | grep -v grep | wc -l`
if [[ $CHECK_GPMMON -ne 0 && -f /home/gpadmin/.pgpass ]]; then
    echo "Install GPCC..."
    # Ref: http://gpcc.docs.pivotal.io/450/topics/install.html
    unzip greenplum-cc-web-4.6.1-LINUX-x86_64.zip
    # ./greenplum-cc-web-4.6.1-LINUX-x86_64/gpccinstall-4.6.1 -c config/gpccinstall_config
    # source /usr/local/greenplum-cc-web/gpcc_path.sh
    # [fix] pq: no pg_hba.conf entry for host "10.3.205.94", user "gpmon", database "gpperfmon", SSL off
    # gpcc start
    # echo "source /usr/local/greenplum-cc-web/gpcc_path.sh" >> /home/gpadmin/.bashrc
    cp /opt/greenplum/config/send_alert.sh $MASTER_DATA_DIRECTORY/gpmetrics/send_alert.sh
fi

echo "Greenplum container is healthy" > /opt/greenplum/stdout
tail -f /opt/greenplum/stdout

