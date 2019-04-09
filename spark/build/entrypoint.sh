#!/bin/bash
set -e

echo "NODE is: `hostname`"
if [ `hostname` == "sparkmaster" ];then
    ./sbin/start-master.sh
    ./sbin/start-history-server.sh
else
    ./sbin/start-slave.sh spark://sparkmaster:7077
fi

tail -f /opt/spark/logs/*
