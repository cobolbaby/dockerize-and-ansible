#! /bin/bash

# 采用最新版镜像4.2，在webui页面创建Greenplum数据库连接时，会提示异常:
# permission denied: "pg_settings" is a system catalog
# GPDB SQL执行语句: 
# UPDATE pg_settings SET setting = 'escape' WHERE name = 'bytea_output';
# 因此回退至4.1版本
docker pull dpage/pgadmin4:4.1

docker run -p 80:80 \
    -e "PGADMIN_DEFAULT_EMAIL=cobolbaby@qq.com" \
    -e "PGADMIN_DEFAULT_PASSWORD=123456" \
    -d dpage/pgadmin4:4.1
