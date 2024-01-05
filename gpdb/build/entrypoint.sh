#!/bin/bash
# set -e

# 启动SSH
sudo /usr/sbin/sshd

# ssh-keygen无回车生成公钥私钥对
ssh-keygen -t rsa -N '' -f ~/.ssh/id_rsa

# [fix] Variables in "/etc/sysctl.conf" not work
# [fix] OCI runtime create failed: sysctl "vm.overcommit_memory " is not in a separate kernel namespace: unknown
# [fix] Command "sysctl -w vm.overcommit_ratio=95" execute failed: bash: fork: Cannot allocate memory
# sudo sysctl -p

# 设置环境变量
# 如果不source，后续的指令将无法执行
source ~/.bashrc
which gpstart

if [ "$ENABLE_RESOURCE_GROUPS" == true ]; then
    # 启动cgroups服务
    # Ref: https://pvtl.force.com/s/article/FATAL--cgroup-Is-Not-Properly-Configured-Gives-The-Error-can-not-find-cgroup-mount-point
    sudo cgconfigparser -l /etc/cgconfig.d/gpdb.conf 
    # Identify the cgroup directory mount point for the node
    grep cgroup /proc/mounts
    # Verify that you set up the Greenplum Database cgroups configuration correctly by running the following commands. 
    # Replace <cgroup_mount_point> with the mount point that you identified in the previous step
    ls -l /sys/fs/cgroup/cpu/gpdb
    ls -l /sys/fs/cgroup/cpuacct/gpdb
fi

# 启动GPDB
if [ "$IS_MASTER" == true ]; then
    echo "NODE is: `hostname`"

    # 遍历config/hostlist
    for host in $(cat config/hostlist)
    do
        # https://docs.vmware.com/en/VMware-Greenplum/6/greenplum-database/install_guide-install_gpdb.html#enabling-passwordless-ssh
        sshpass -p "Ho1Z9JO7AoC90jA2" ssh-copy-id -o StrictHostKeyChecking=no -i ~/.ssh/id_rsa.pub gpadmin@$host
    done

    gpssh-exkeys -f config/hostlist
    echo "Key exchange complete"

    if [ ! -d $MASTER_DATA_DIRECTORY ]; then
        echo 'Master directory does not exist. Initialize gpdb...'

        if [ "$MIRROR_STRATEGY" == "Spread" ]; then
            # 假设segment主机为两台，节点数为2，执行初始化命令gpinitsystem
            # GPDB5加上-S也无法启用spread mirror模式，并且还会报错
            # GPDB6加上--mirror-mode=spread也无法启用spread mirror模式，并且还会报错
            gpinitsystem -a -c config/gpinitsystem_config --mirror-mode=spread
        else
            gpinitsystem -a -c config/gpinitsystem_config
        fi
        echo "Master node initialized"
        # receive connection from anywhere.. This should be changed!!
        echo "host  all gpadmin 0.0.0.0/0   md5" >> $MASTER_DATA_DIRECTORY/pg_hba.conf
        # gpstop -u

        # Limit Pivotal Greenplum Logging Information
        # Ref: https://docs.vmware.com/en/VMware-Greenplum/6/greenplum-database/ref_guide-config_params-guc-list.html
        gpconfig -c log_min_messages -v error
        gpconfig -c log_statement -v none
        # gpstop -u

        # Ps: 修改配置需要处于服务启动的情况下
        # [fix] too many clients already
        # change the client max connections and reload the configuration
        # The value on the segments must be greater than the value on the master. 
        # The recommended value of max_connections on segments is 5-10 times the value on the master.
        gpconfig -c max_connections -v 2500 -m 500
        # [fix] the limit of distributed transactions has been reached
        # max_prepared_transactions max_val: 1000 
        gpconfig -c max_prepared_transactions -v 500 -m 500
        # ...
        # [ERROR]:-gpstop error: Active connections. Aborting shutdown...
        # gpstop -r
        gpstop -M fast -a
        gpstart -a
        gpconfig -s max_connections
        gpconfig -s max_prepared_transactions
    else
        echo 'Master exists. Restart gpdb...'

        # [fix] ExecutionError: 'non-zero rc: 1' occured.  Details: 'ssh -o StrictHostKeyChecking=no -o ServerAliveInterval=60 sdw4 ". /usr/local/greenplum-db/./greenplum_path.sh; $GPHOME/sbin/gpoperation.py"'  cmd had rc=1 completed=True halted=False
        # OSError: [Errno 17] File exists: '~/gpAdminLogs'
        # Deploy again...
        gpstart -a
    fi
else
    echo "NODE is: `hostname`"
fi

# 【推荐手动】启用Standby
# gpinitstandby -s gp6smdw

# 【已废弃】启动性能数据收集器
# gpperfmon_install --enable --password gpmon --port 5432
# gpstop -r

# 启动GPCC
if [[ "$IS_MASTER" == true && "$ENABLE_GPCC" == true ]]; then
    echo "Install GPCC..."
    # TODO: 判断数据库中是否存在用户gpmon，有才执行，没不执行
    echo "*:5432:gpperfmon:gpmon:gpmon" > ~/.pgpass
    sudo chmod 600 ~/.pgpass
    # Ref: http://gpcc.docs.pivotal.io/450/topics/install.html
    unzip greenplum-cc-web-6.9.1-gp6-rhel7-x86_64.zip
    # v4.7支持了auto参数配置，用于自动化安装
    ./greenplum-cc-web-6.9.1-gp6-rhel7-x86_64/gpccinstall-6.9.1 -auto
    # Do you agree to the Pivotal Greenplum Command Center End User License Agreement? Yy/Nn (Default=Y)
    # Y
    # Where would you like to install Greenplum Command Center? (Default=/usr/local)
    # /usr/local
    # What would you like to name this installation of Greenplum Command Center? (Default=gpcc)
    # gpcc
    # What port would you like gpcc webserver to use? (Default=28080)
    # 28080
    # Would you like to enable kerberos? Yy/Nn (Default=N)
    # N
    # Would you like enable SSL? Yy/Nn (Default=N)
    # N
    # Please choose a display language (Default=English)
    # 1.  English
    # 2.  Chinese
    # 3.  Korean
    # 1
    # Installation in progress...
    # Successfully installed Greenplum Command Center.
    source /usr/local/greenplum-cc/gpcc_path.sh
    echo "source /usr/local/greenplum-cc/gpcc_path.sh" >> ~/.bashrc
    # 修改初始密码
    psql -d postgres -c "alter user gpmon with password 'gpmon';"
    echo "*:5432:gpperfmon:gpmon:gpmon" > ~/.pgpass
    # [fix] pq: no pg_hba.conf entry for host "10.3.205.94", user "gpmon", database "gpperfmon", SSL off

    gpcc start
    cp /opt/greenplum/config/send_alert.sh $MASTER_DATA_DIRECTORY/gpmetrics/send_alert.sh
fi

# Install gpbackup/gprestore
# gppkg -i pivotal_greenplum_backup_restore-1.23.0-gp6-rhel-x86_64.gppkg

if [ -z "$1" ]; then
    echo "Greenplum container is healthy" > /opt/greenplum/stdout
    tail -f /opt/greenplum/stdout
else
    "$@"
fi
