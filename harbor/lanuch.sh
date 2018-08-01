#! /bin/bash
wget https://storage.googleapis.com/harbor-releases/harbor-offline-installer-v1.5.2.tgz
tar -zxvf harbor-offline-installer-v1.5.2.tgz -C /opt

# harbor.cfg 修改hostname、harbor_admin_password
cp config/harbor.cfg /opt/harbor/

cd /opt/harbor && ./install.sh