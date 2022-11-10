#! /bin/bash

# https://www.pgadmin.org/docs/pgadmin4/latest/container_deployment.html
# /pgadmin4 $ id
# uid=5050(pgadmin) gid=5050(pgadmin)
sudo chown -R 5050:5050 /tmp/pgadmin

# git clone https://github.com/pgadmin-org/pgadmin4.git
# cd pgadmin4
# git checkout REL-5_7
# git apply gpdb6-support.patch
# make docker

docker run -p 80:80 \
    --name pgadmin5 \
    -v /tmp/pgadmin:/var/lib/pgadmin \
    -e "PGADMIN_DEFAULT_EMAIL=cobolbaby@qq.com" \
    -e "PGADMIN_DEFAULT_PASSWORD=123456" \
    --restart always \
    -d registry.inventec/infra/dpage/pgadmin4:5.7
