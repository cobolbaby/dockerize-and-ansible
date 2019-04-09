#!/bin/bash
cd `dirname $0`

# 判断是否存在Ansible
_=`command -v ansible`
if [ $? -ne 0 ]; then
  printf "You don\'t seem to install %s.\n" Ansible
  exit
fi

if [ -n "$1" ]; then
  BRANCH=$1
else
  # BRANCH=4.3.30.4
  # BRANCH=5.15.1
  # BRANCH=gpcc
  BRANCH=5.17.0
fi
TAGNAME=development/gpdb:${BRANCH}
REGISTRY=registry.inventec
echo "REGISTRY=${REGISTRY}" > deploy.tao/bin/.env
echo "TAGNAME=${TAGNAME}" >> deploy.tao/bin/.env
INVENTORY=../inventory.tao

# 一定要先杀掉mdw，否则gpdb启动的时候就需要做恢复了
ansible -i $INVENTORY gpdb-mdw  -m raw -a "cd /opt/greenplum5/bin && /opt/bin/docker-compose -f docker-compose-master.yml down"
ansible -i $INVENTORY gpdb-sdw1 -m raw -a "cd /opt/greenplum5/bin && /opt/bin/docker-compose -f docker-compose-segment.1.yml down"
ansible -i $INVENTORY gpdb-sdw2 -m raw -a "cd /opt/greenplum5/bin && /opt/bin/docker-compose -f docker-compose-segment.2.yml down"
ansible -i $INVENTORY gpdb-sdw3 -m raw -a "cd /opt/greenplum5/bin && /opt/bin/docker-compose -f docker-compose-segment.3.yml down"
ansible -i $INVENTORY gpdb-smdw -m raw -a "cd /opt/greenplum5/bin && /opt/bin/docker-compose -f docker-compose-standby.yml down"
# exit

# 安装Docker
# ansible -i $INVENTORY all -m copy -a "src=../docker-ce_18.06.1~ce~3-0~ubuntu_amd64.deb dest=/tmp/" -b -f 5
# fix: docker-ce depends on libltdl7 (>= 2.4.6); however: Package libltdl7 is not installed.
# ansible -i $INVENTORY all -m apt -a "name=libltdl7 state=latest install_recommends=no" -b -f 5
# ansible -i $INVENTORY all -m raw -a "dpkg -i /tmp/docker-ce_18.06.1~ce~3-0~ubuntu_amd64.deb" -b -f 5

# 添加私有仓库地址
# ansible -i $INVENTORY all -m shell -a "echo '10.99.170.92    registry.inventec' >> /etc/hosts" -b
# ansible -i $INVENTORY all -m raw -a "cat /etc/hosts" -b
# ansible -i $INVENTORY all -m shell -a "echo '{\"insecure-registries\": [\"registry.inventec\"]}' > /etc/docker/daemon.json" -b
# ansible -i $INVENTORY all -m raw -a "cat /etc/docker/daemon.json" -b
# ansible -i $INVENTORY all -m service -a "name=docker state=restarted" -b

# 创建挂载在外部的数据目录
# ansible -i $INVENTORY all -m raw -a "ls -la /data/hdd" -b
# ansible -i $INVENTORY all -m file -a "path=/data/hdd state=absent"
# ansible -i $INVENTORY all -m file -a "path=/data/ssd state=absent"
# ansible -i $INVENTORY gpdb-master  -m file -a "dest=/data/hdd/disk1/gp5data/gpmaster mode=777 state=directory" -b
# ansible -i $INVENTORY gpdb-segment -m file -a "dest=/data/hdd/disk1/gp5data/gpsegment/primary mode=777 state=directory" -f 5 -b
# ansible -i $INVENTORY gpdb-segment -m file -a "dest=/data/hdd/disk1/gp5data/gpsegment/mirror mode=777 state=directory" -f 5 -b
# ansible -i $INVENTORY gpdb-segment -m file -a "dest=/data/hdd/disk2/gp5data/gpsegment/primary mode=777 state=directory" -f 5 -b
# ansible -i $INVENTORY gpdb-segment -m file -a "dest=/data/hdd/disk2/gp5data/gpsegment/mirror mode=777 state=directory" -f 5 -b
# ansible -i $INVENTORY gpdb -m file -a "dest=/data/hdd/disk6/gp5data mode=777 state=directory" -f 5 -b
# ansible -i $INVENTORY gpdb-segment -m file -a "dest=/data/ssd/gp5space01 mode=777 state=directory" -f 5 -b

# 同步配置文件
# ansible -i $INVENTORY all -m file -a "path=/opt/greenplum5 state=absent" -b -f 5
ansible -i $INVENTORY gpdb-mdw -m copy -a "src=deploy.tao/config dest=/opt/greenplum5" -b

# 执行启动命令
ansible -i $INVENTORY gpdb -m copy -a "src=deploy.tao/bin dest=/opt/greenplum5" -b -f 5
ansible -i $INVENTORY gpdb-sdw1 -m raw -a "cd /opt/greenplum5/bin && /opt/bin/docker-compose -f docker-compose-segment.1.yml up -d"
ansible -i $INVENTORY gpdb-sdw2 -m raw -a "cd /opt/greenplum5/bin && /opt/bin/docker-compose -f docker-compose-segment.2.yml up -d"
ansible -i $INVENTORY gpdb-sdw3 -m raw -a "cd /opt/greenplum5/bin && /opt/bin/docker-compose -f docker-compose-segment.3.yml up -d"
ansible -i $INVENTORY gpdb-smdw -m raw -a "cd /opt/greenplum5/bin && /opt/bin/docker-compose -f docker-compose-standby.yml up -d"
ansible -i $INVENTORY gpdb-mdw  -m raw -a "cd /opt/greenplum5/bin && /opt/bin/docker-compose -f docker-compose-master.yml up -d"