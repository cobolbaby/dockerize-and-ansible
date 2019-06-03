#!/bin/bash

# docker node update --label-add alias=bdc01.infra.dev.tj.itc.inventec gpmaster
# docker node update --label-add alias=bdc02.infra.dev.tj.itc.inventec gp02
# docker node update --label-add alias=bdc03.infra.dev.tj.itc.inventec gp03
# docker node update --label-add alias=bdc04.infra.dev.tj.itc.inventec gp04
# mkdir /disk/kafka && chmod -R 777 /disk/kafka
docker stack deploy -c docker-compose.yml kafka

# deploy connect...