#!/bin/bash

# docker node update --label-add alias=bdc01.infra.dev.tj.itc.inventec gpmaster
# docker node update --label-add alias=bdc02.infra.dev.tj.itc.inventec gp02
# docker node update --label-add alias=bdc03.infra.dev.tj.itc.inventec gp03
# docker node update --label-add alias=bdc04.infra.dev.tj.itc.inventec gp04
# mkdir /data/ceph && chmod -R 777 /data/ceph

# 推送启动脚本至部署目录
INVENTORY_FILE=../inventory.dev
IMAGE=registry.inventec/hub/ceph/daemon:v3.2.5-stable-3.2-luminous-centos-7

# 传出配置文件
# ansible -i $INVENTORY_FILE ceph -m raw -a "docker rm $(docker stop $(docker ps -a --filter ancestor=${IMAGE} -q))"
ansible -i $INVENTORY_FILE ceph -m raw -a "docker system prune --force"
ansible -i $INVENTORY_FILE ceph -m raw -a "rm -rf /data/ceph" -b
ansible -i $INVENTORY_FILE ceph -m raw -a "rm -rf /etc/ceph" -b
# ansible -i $INVENTORY_FILE etcd -m raw -a "docker exec -ti pt-etcd1 etcdctl rm /ceph-config -r" -b