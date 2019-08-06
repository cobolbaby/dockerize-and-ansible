#!/bin/bash

# 推送启动脚本至部署目录
INVENTORY_FILE=../inventory.dev

# 传出配置文件
ansible -i $INVENTORY_FILE mongo -m copy -a "src=deploy.dev/ dest=/opt/mongo"
# ansible -i $INVENTORY_FILE mongo -m file -a "path=/data/ssd1/mongo state=absent" -f 5
ansible -i $INVENTORY_FILE mongo -m file -a "dest=/data/ssd1/mongo owner=999 group=999 mode=700 state=directory" -f 5 -b 

# 执行启动命令
ansible -i $INVENTORY_FILE mongo -m shell -a "cd /opt/mongo && docker-compose up -d"