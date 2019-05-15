#! /bin/bash

cd `dirname $0`

sudo mkdir -p conf storage plugins
sudo chmod -R 777 conf storage plugins

sudo docker-compose up -d
