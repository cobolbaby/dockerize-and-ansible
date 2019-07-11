#!/bin/bash

# docker node update --label-add alias=bdc01.infra.dev.tj.itc.inventec gpmaster
# docker node update --label-add alias=bdc02.infra.dev.tj.itc.inventec gp02
# docker node update --label-add alias=bdc03.infra.dev.tj.itc.inventec gp03
# docker node update --label-add alias=bdc04.infra.dev.tj.itc.inventec gp04
# mkdir /disk/kafka && chmod -R 777 /disk/kafka

# 推送启动脚本至部署目录
INVENTORY_FILE=../../inventory.dev

# # 传出配置文件
# ansible -i $INVENTORY_FILE kafka -m copy -a "src=jmx_exporter dest=/opt/kafka" -b
# ansible -i $INVENTORY_FILE broker1 -m copy -a "src=deploy.dev/ dest=/opt/kafka" -b
# # ansible -i $INVENTORY_FILE kafka -m file -a "path=/disk/kafka state=absent" -f 5 -b
# # ansible -i $INVENTORY_FILE kafka -m file -a "dest=/disk/kafka mode=777 state=directory" -f 5 -b
# # ansible -i $INVENTORY_FILE gpdb-sdw2 -m file -a "path=/disk/zookeeper state=absent" -f 5 -b
# ansible -i $INVENTORY_FILE gpdb-sdw2 -m file -a "dest=/disk/zookeeper/data mode=777 state=directory" -f 5 -b
# ansible -i $INVENTORY_FILE gpdb-sdw2 -m file -a "dest=/disk/zookeeper/datalog mode=777 state=directory" -f 5 -b

# # 执行启动命令
# ansible -i $INVENTORY_FILE broker1 -m shell -a "/opt/kafka/bin/start.sh" -b