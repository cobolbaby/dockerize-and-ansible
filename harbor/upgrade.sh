#!/bin/bash

mv /opt/harbor /opt/harbor_v1.9.4
sudo cp -r /data/database /opt/harbor_v1.9.4_database
tar -zxvf ~/harbor-offline-installer-v2.0.6.tgz -C /opt
cd /opt/harbor
docker load -i harbor.v2.0.6.tar.gz
cp /opt/harbor_v1.9.4/harbor.yml .
docker run -it --rm -v /:/hostfs goharbor/prepare:v2.0.6 migrate -i /opt/harbor/harbor.yml
./install.sh
docker-compose up -d

# mv /opt/harbor /opt/harbor_v2.0.6
# sudo cp -r /data/database /opt/harbor_v2.0.6_database
# tar -zxvf ~/harbor-offline-installer-v2.1.4.tgz -C /opt
# cd /opt/harbor
# docker load -i harbor.v2.1.4.tar.gz
# cp /opt/harbor_v2.0.6/harbor.yml .
# docker run -it --rm -v /:/hostfs goharbor/prepare:v2.1.4 migrate -i /opt/harbor/harbor.yml
# ./install.sh
# docker-compose up -d
