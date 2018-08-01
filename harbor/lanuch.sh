#! /bin/bash
wget https://github.com/vmware/harbor/archive/v1.5.2.tar.gz
tar -zxvf v1.5.2.tar.gz -C ／opt
cd /opt/harbor

# harbor.cfg 修改hostname、harbor_admin_password
cp config/harbor.cfg .
./install.sh