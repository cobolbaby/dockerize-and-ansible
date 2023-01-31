#!/bin/bash
cd `dirname $0`
# docker run --rm telegraf:1.13.0-alpine telegraf config > telegraf.default.conf
# sed '/^\s*#\|^$/d' ./deploy.dev/config/telegraf/telegraf.default.conf > ./deploy.dev/config/telegraf/telegraf.conf
# remove the option: [[outputs.influxdb]]

# 推送启动脚本至部署目录
INVENTORY_FILE=../inventory.dev

# 传出配置文件
# ansible -i $INVENTORY_FILE all -m file -a "dest=/opt/prometheus/textfile mode=777 state=directory" -b
# ansible -i $INVENTORY_FILE all -m copy -a "src=deploy.dev/config/node-exporter dest=/opt/prometheus/config/" -b
# ansible -i $INVENTORY_FILE all -m raw -a "chmod +x /opt/prometheus/config/node-exporter/smartmon.sh" -b
# ansible -i $INVENTORY_FILE all -m cron -a 'name="smartmon" state=absent'
# ansible -i $INVENTORY_FILE all -m cron -a 'name="smartmon" minute=0 hour=*/4 job="/opt/prometheus/config/node-exporter/smartmon.sh > /opt/prometheus/textfile/smartmon.prom 2>&1"' -b
# ansible -i $INVENTORY_FILE all -m copy -a "src=deploy.dev/docker-compose-node.yml dest=/opt/prometheus/" -b
# ansible -i $INVENTORY_FILE all -m raw -a "docker-compose -f /opt/prometheus/docker-compose-node.yml up -d"
# exit

# ansible -i $INVENTORY_FILE prom01 -m file -a "dest=/data/hdd4/prometheus/data owner=999 group=999 mode=777 state=directory" -b

# 传出配置文件
ansible -i $INVENTORY_FILE prom01 -m copy -a "src=deploy.dev/ dest=/opt/prometheus"

# 执行启动命令
ansible -i $INVENTORY_FILE prom01 -m raw -a "chmod +x /opt/prometheus/start.sh"
ansible -i $INVENTORY_FILE prom01 -m raw -a "/opt/prometheus/start.sh"
