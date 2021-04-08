#! /bin/bash

# 采用镜像4.2，在webui页面创建Greenplum数据库连接时，会提示异常:
# permission denied: "pg_settings" is a system catalog
# GPDB SQL执行语句: 
# UPDATE pg_settings SET setting = 'escape' WHERE name = 'bytea_output';

# /pgadmin4 $ id
# uid=5050(pgadmin) gid=5050(pgadmin)
sudo chown -R 5050:5050 /opt/pgadmin4/pgadmin

# git clone git://git.postgresql.org/git/pgadmin4.git
# cd pgadmin4
# git apply gpdb6-support.patch
# make docker

docker run -p 80:80 \
    --name pgadmin4 \
    -v /opt/pgadmin4/pgadmin:/var/lib/pgadmin \
    -e "PGADMIN_DEFAULT_EMAIL=cobolbaby@qq.com" \
    -e "PGADMIN_DEFAULT_PASSWORD=123456" \
    --restart always \
    -d dpage/pgadmin4:4.29

docker run -p 80:80 \
    --name pgadmin5 \
    -v /opt/pgadmin4/pgadmin5:/var/lib/pgadmin \
    -e "PGADMIN_DEFAULT_EMAIL=cobolbaby@qq.com" \
    -e "PGADMIN_DEFAULT_PASSWORD=123456" \
    --restart always \
    -d registry.inventec/infra/pgadmin4:5.1