#!/bin/bash
cd `dirname $0`
# docker node update --label-add alias=bdc01.infra.dev.itc.inventec kubernetes-101
# docker node update --label-add alias=bdc02.infra.dev.itc.inventec kubernetes-102
# docker node update --label-add alias=bdc03.infra.dev.itc.inventec kubernetes-103
# docker node update --label-add alias=bdc04.infra.dev.itc.inventec kubernetes-104
# mkdir /disk/kafka && chmod -R 777 /disk/kafka

# 推送启动脚本至部署目录
INVENTORY_FILE=../inventory.dev

# ansible -i $INVENTORY_FILE kafka -m file -a "dest=/disk/kafka mode=777 state=directory" -f 5 -b
# ansible -i $INVENTORY_FILE kafka -m file -a "path=/disk/zookeeper state=absent" -f 5 -b
# ansible -i $INVENTORY_FILE kafka -m file -a "dest=/disk/zookeeper/datalog mode=777 state=directory" -b
# ansible -i $INVENTORY_FILE kafka -m file -a "dest=/disk/zookeeper/logs mode=777 state=directory" -b

# 传出配置文件
ansible -i $INVENTORY_FILE kafka -m copy -a "src=jmx_exporter dest=/opt/kafka"
ansible -i $INVENTORY_FILE kafka -m copy -a "src=deploy.dev/ dest=/opt/kafka"

# 执行启动命令
ansible -i $INVENTORY_FILE broker1 -m shell -a "/opt/kafka/bin/start.sh"
