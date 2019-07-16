#! /bin/bash

cd `dirname $0`

sudo mkdir -p storage
sudo chown -R 10001:root storage

docker-compose up -d
