ARG VERSION
FROM registry.inventec/proxy/dpage/pgadmin4:${VERSION}
LABEL maintainer="Zhang.Xing-Long@inventec.com"

COPY patch/gpdb6-support.patch /tmp

USER root

RUN apk add patch \
    && cd /pgadmin4 \
    && patch -p2 < /tmp/gpdb6-support.patch

USER pgadmin

# 升级 psycopg 依赖的版本，解决文件描述符用尽的问题，但总是失败
# RUN /venv/bin/python3 -m pip install --no-cache-dir --upgrade psycopg2-binary
