#! /bin/bash

# 采用镜像4.2，在webui页面创建Greenplum数据库连接时，会提示异常:
# permission denied: "pg_settings" is a system catalog
# GPDB SQL执行语句: 
# UPDATE pg_settings SET setting = 'escape' WHERE name = 'bytea_output';

docker run -p 80:80 \
    -e "PGADMIN_DEFAULT_EMAIL=cobolbaby@qq.com" \
    -e "PGADMIN_DEFAULT_PASSWORD=123456" \
    --restart always \
    -d dpage/pgadmin4:4.16
