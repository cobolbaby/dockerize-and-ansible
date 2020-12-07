FROM registry.inventec/hub/postgres:11.8
LABEL maintainer="Zhang.Xing-Long@inventec.com"

RUN set -ex \
    && export DEBIAN_FRONTEND=noninteractive \
    && echo 'APT::Install-Recommends "0";\nAPT::Install-Suggests "0";' > /etc/apt/apt.conf.d/01norecommend \
    && apt-get update -y \
    && apt-get install -y curl postgresql-server-dev-$PG_MAJOR net-tools vim-tiny \
    && cd /opt \
    && curl -sSL -o pg_partman-4.4.0.tar.gz https://github.com/pgpartman/pg_partman/archive/v4.4.0.tar.gz \
    && tar -xzf pg_partman-4.4.0.tar.gz \
    && cd pg_partman-4.4.0 \
    && make install \
    && rm /opt/pg_partman-4.4.0.tar.gz \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /root/.cache
