#! /bin/bash

# https://www.pgadmin.org/docs/pgadmin4/latest/container_deployment.html
# /pgadmin4 $ id
# uid=5050(pgadmin) gid=5050(pgadmin)
# sudo chown -R 5050:5050 /data/pgadmin4/pgadmin9

docker compose up -d

# Chrome 新版针对非 HTTPS 访问的情况，剪切板功能受限，推荐使用 TLS 证书，但要注意证书文件的命名
# docker compose -f docker-compose-ssl.yml up -d

<< comment

# 如果因为忘记了超管用户的密码而造成账户被锁，请参考
# https://www.pgadmin.org/docs/pgadmin4/development/restore_locked_user.html

docker run -it --rm \
    -v /data/pgadmin4/pgadmin9:/var/lib/pgadmin \
    --entrypoint=/bin/bash \
    registry.inventec/proxy/nouchka/sqlite3

comment