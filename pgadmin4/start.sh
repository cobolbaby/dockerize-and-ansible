#! /bin/bash

# https://www.pgadmin.org/docs/pgadmin4/latest/container_deployment.html
# /pgadmin4 $ id
# uid=5050(pgadmin) gid=5050(pgadmin)
# sudo chown -R 5050:5050 /data/pgadmin4/pgadmin8

docker run -d --name pgadmin8 \
    -p 443:443 \
    -v /data/pgadmin4/pgadmin8:/var/lib/pgadmin \
    -v /data/pgadmin4/certs:/certs \
    -e "PGADMIN_ENABLE_TLS=True" \
    -e "PGADMIN_DEFAULT_EMAIL=cobolbaby@qq.com" \
    -e "PGADMIN_DEFAULT_PASSWORD=123456" \
    -e "GUNICORN_THREADS=50" \
    -e "PGADMIN_CONFIG_MAX_LOGIN_ATTEMPTS=10" \
    --restart always \
    registry.inventec/infra/dpage/pgadmin4:8.14

<< comment

# sudo cp -rf /data/pgadmin4/pgadmin /data/pgadmin4/pgadmin8
# sudo chown -R 5050:5050 /data/pgadmin4/pgadmin8

docker run -d --name pgadmin8 \
    -p 80:80 \
    -e "PGADMIN_DEFAULT_EMAIL=cobolbaby@qq.com" \
    -e "PGADMIN_DEFAULT_PASSWORD=123456" \
    -e "GUNICORN_THREADS=50" \
    -e "PGADMIN_CONFIG_MAX_LOGIN_ATTEMPTS=10" \
    --restart always \
    registry.inventec/proxy/dpage/pgadmin4:8.14

docker run -d --name pgadmin8 \
    -p 80:80 \
    -v /data/pgadmin4/pgadmin8:/var/lib/pgadmin \
    -e "PGADMIN_DEFAULT_EMAIL=cobolbaby@qq.com" \
    -e "PGADMIN_DEFAULT_PASSWORD=123456" \
    -e "GUNICORN_THREADS=50" \
    -e "PGADMIN_CONFIG_MAX_LOGIN_ATTEMPTS=10" \
    --restart always \
    registry.inventec/infra/dpage/pgadmin4:8.14

# 1) 直接将 pgadmin 从 5.7 升级到 8.3 会有坑，会遇到 Server Parameter 无法修改的情况
# 需要将 Server 配置进行一个导出，修正，再导入。

# 2) 如果因为忘记了超管用户的密码而造成账户被锁，请参考
# https://www.pgadmin.org/docs/pgadmin4/development/restore_locked_user.html
# docker run -it --rm -v /data/pgadmin4/pgadmin8:/var/lib/pgadmin --entrypoint=/bin/bash registry.inventec/proxy/nouchka/sqlite3

# 3) Chrome 新版针对非 HTTPS 访问的情况，剪切板功能受限，推荐使用 TLS 证书，但要注意证书文件的命名

comment