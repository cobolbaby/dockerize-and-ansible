ARG VERSION=8.14
FROM registry.inventec/proxy/dpage/pgadmin4:${VERSION}
LABEL maintainer="Zhang.Xing-Long@inventec.com"

COPY patch/pgadmin8-support-gpdb6.patch /tmp

USER root

RUN apk add patch \
    && cd /pgadmin4 \
    && patch -p2 < /tmp/pgadmin8-support-gpdb6.patch

USER pgadmin

