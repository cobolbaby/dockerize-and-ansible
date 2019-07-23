#! /bin/bash
wget https://storage.googleapis.com/harbor-releases/release-1.7.0/harbor-offline-installer-v1.7.1.tgz
tar -zxvf harbor-offline-installer-v1.7.1.tgz -C /opt

# harbor.cfg 修改hostname、harbor_admin_password
# sed ...

# 如果是CoreOS，还需要修改prepare文件头python执行文件的引用路径

cd /opt/harbor && ./install.sh
