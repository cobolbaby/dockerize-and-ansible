#! /bin/bash

cd `dirname $0`

sudo mkdir -p conf storage plugins
sudo chown -R 100:101 conf storage plugins

sudo docker-compose up -d
