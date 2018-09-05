#!/bin/bash
. ./init.sh

# 传出配置文件
ansible -i $INVENTORY_FILE master -m cron -a 'name="pi" hour=*/2 job="/opt/sparkv2/submit.sh >> /opt/sparkv2/logs/jobs.log"'
# ansible -i $INVENTORY_FILE master -m cron -a 'name="pi" state=absent'