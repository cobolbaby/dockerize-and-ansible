#! /bin/bash
docker pull dpage/pgadmin4

docker run -p 80:80 \
    -e "PGADMIN_DEFAULT_EMAIL=cobolbaby@qq.com" \
    -e "PGADMIN_DEFAULT_PASSWORD=123456" \
    -d dpage/pgadmin4
