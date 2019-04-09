#!/bin/bash
. ./init.sh

# INVENTORY_FILE=../inventory.dev
INVENTORY_FILE=../inventory.prod

# 传出配置文件
ansible -i $INVENTORY_FILE spark-master -m cron -a 'name="pi" state=absent'
ansible -i $INVENTORY_FILE spark-master -m cron -a 'name="pi" minute=0 hour=*/2 job="/opt/sparkv2/submit.sh >> /opt/sparkv2/logs/jobs.log 2>&1"'