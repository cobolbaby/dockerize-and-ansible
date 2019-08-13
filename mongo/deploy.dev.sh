#!/bin/bash

# 推送启动脚本至部署目录
INVENTORY_FILE=../inventory.dev

# 传出配置文件
ansible -i $INVENTORY_FILE mongo -m copy -a "src=deploy.dev/ dest=/opt/mongo"
# ansible -i $INVENTORY_FILE mongo -m file -a "path=/data/ssd1/mongo state=absent"
ansible -i $INVENTORY_FILE mongo -m file -a "dest=/data/ssd1/mongo/configdb owner=999 group=999 mode=700 state=directory" -b
ansible -i $INVENTORY_FILE mongo -m file -a "dest=/data/ssd1/mongo/db owner=999 group=999 mode=700 state=directory" -b
ansible -i $INVENTORY_FILE mongo -m file -a "dest=/data/ssd1/mongo/logs owner=999 group=999 mode=700 state=directory" -b

# 执行启动命令
ansible -i $INVENTORY_FILE mongo -m shell -a "cd /opt/mongo && docker-compose up -d"
