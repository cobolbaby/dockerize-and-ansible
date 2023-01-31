ARG VERSION
FROM registry.inventec/proxy/gitlab/gitlab-ce:${VERSION}
LABEL maintainer="Zhang.Xing-Long@inventec.com"
ARG VERSION

COPY patch/gitlab-${VERSION}.patch /tmp

RUN apt-get update \
    && apt-get install -y patch \
    && rm -rf /var/lib/apt/lists/* \
    && cd /opt/gitlab \
    && patch -p1 < /tmp/gitlab-${VERSION}.patch
