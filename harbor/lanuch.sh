#! /bin/bash
wget https://storage.googleapis.com/harbor-releases/release-1.7.0/harbor-offline-installer-v1.7.1.tgz
tar -zxvf harbor-offline-installer-v1.7.1.tgz -C /opt

# harbor.cfg 修改hostname、harbor_admin_password
cp config/harbor.cfg /opt/harbor/

cd /opt/harbor && ./install.sh
