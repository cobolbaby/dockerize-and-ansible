#!/bin/bash

# mv /opt/harbor /opt/harbor_v1.9.4
# sudo cp -r /data/database /opt/harbor_v1.9.4_database
# tar -zxvf ~/harbor-offline-installer-v2.0.6.tgz -C /opt
# cd /opt/harbor
# docker load -i harbor.v2.0.6.tar.gz
# cp /opt/harbor_v1.9.4/harbor.yml .
# docker run -it --rm -v /:/hostfs goharbor/prepare:v2.0.6 migrate -i /opt/harbor/harbor.yml
# ./install.sh
# docker-compose up -d

# mv /opt/harbor /opt/harbor_v2.0.6
# sudo cp -r /data/database /opt/harbor_v2.0.6_database
# tar -zxvf ~/harbor-offline-installer-v2.1.4.tgz -C /opt
# cd /opt/harbor
# docker load -i harbor.v2.1.4.tar.gz
# cp /opt/harbor_v2.0.6/harbor.yml .
# docker run -it --rm -v /:/hostfs goharbor/prepare:v2.1.4 migrate -i /opt/harbor/harbor.yml
# ./install.sh
# docker-compose up -d

# mv /opt/harbor /opt/harbor_v2.1.4
# sudo cp -r /data/database /opt/harbor_v2.1.4_database
# tar -zxvf ~/harbor-offline-installer-v2.3.5.tgz -C /opt
# cd /opt/harbor
# docker load -i harbor.v2.3.5.tar.gz
# cp /opt/harbor_v2.1.4/harbor.yml .
# docker run -it --rm -v /:/hostfs goharbor/prepare:v2.3.5 migrate -i /opt/harbor/harbor.yml
# ./install.sh
# docker-compose up -d

# 升级已有版本至 2.5.4
# cd /opt/harbor
# docker-compose down
# cd ~
# wget https://github.com/goharbor/harbor/releases/download/v2.5.4/harbor-offline-installer-v2.5.4.tgz
# mv /opt/harbor /opt/harbor_v2.3.5
# sudo cp -r /data/database /opt/harbor_v2.3.5_database
# tar -zxvf ~/harbor-offline-installer-v2.5.4.tgz -C /opt
# cd /opt/harbor
# docker load -i harbor.v2.5.4.tar.gz
# cp /opt/harbor_v2.3.5/harbor.yml .
# docker run -it --rm -v /:/hostfs goharbor/prepare:v2.5.4 migrate -i /opt/harbor/harbor.yml
# sudo ./install.sh --with-trivy --with-chartmuseum

# 升级已有版本至 2.7.3
cd /opt/harbor
docker-compose down
cd ~
wget https://github.com/goharbor/harbor/releases/download/v2.7.3/harbor-offline-installer-v2.7.3.tgz
mv /opt/harbor /opt/harbor_v2.5.4
sudo cp -r /data/database /opt/harbor_v2.5.4_database
tar -zxvf ~/harbor-offline-installer-v2.7.3.tgz -C /opt
cd /opt/harbor
docker load -i harbor.v2.7.3.tar.gz
cp /opt/harbor_v2.5.4/harbor.yml .
docker run -it --rm -v /:/hostfs goharbor/prepare:v2.7.3 migrate -i /opt/harbor/harbor.yml
sudo ./install.sh --with-trivy --with-chartmuseum
