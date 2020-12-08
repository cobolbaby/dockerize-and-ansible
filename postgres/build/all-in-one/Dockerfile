ARG PG_MAJOR=12.5

FROM registry.inventec/hub/postgres:$PG_MAJOR
LABEL maintainer="Zhang.Xing-Long@inventec.com"

ARG PG_MAJOR
ARG PGHOME=/home/postgres

RUN export DEBIAN_FRONTEND=noninteractive \
    && echo 'APT::Install-Recommends "0";\nAPT::Install-Suggests "0";' > /etc/apt/apt.conf.d/01norecommend \
    && apt-get update -y \
    # 通用包
    && apt-get install -y vim-tiny curl jq pigz net-tools unzip --fix-missing \
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /root/.cache

# 数据库的扩展需要依赖postgresql-server-dev-$PG_MAJOR/make/gcc
# patroni包下载需要依赖pip，编译的时候需要依赖wheel/gcc/python3-dev
# 用于编译的包，最后要被清理掉
RUN apt-get update -y \
    && apt-get install -y postgresql-server-dev-$PG_MAJOR python3-pip python3-wheel python3-dev make gcc --fix-missing \
\
    # 安装Patroni
    && pip3 install setuptools \
    && pip3 install psycopg2-binary \
    && pip3 install patroni[etcd] \
    && pip3 uninstall -y setuptools \
\
    # 分区表管理工具
    && curl -sSL -o /tmp/pg_partman-4.4.0.tar.gz https://github.com/pgpartman/pg_partman/archive/v4.4.0.tar.gz \
    && tar -xzf /tmp/pg_partman-4.4.0.tar.gz -C /tmp/  \
    && cd /tmp/pg_partman-4.4.0 \
    # && make install \
    && make NO_BGW=1 install \
    && rm -rf /tmp/pg_partman-4.4.0* \
\
    # 表，索引在线重建工具
    && curl -sSL -o /tmp/pg_repack-1.4.5.zip http://api.pgxn.org/dist/pg_repack/1.4.5/pg_repack-1.4.5.zip \
    && unzip /tmp/pg_repack-1.4.5.zip -d /tmp/ \
    && cd /tmp/pg_repack-1.4.5 \
    && apt-get install -y libssl-dev zlib1g-dev \
    && make && make install \
    && rm -rf /tmp/pg_repack-1.4.5* \
    && apt-get purge -y libssl-dev zlib1g-dev \
\
    # 备份工具
    && apt-get install -y pgbackrest \
    && mkdir -p -m 770 /var/log/pgbackrest \
    && chown postgres:postgres /var/log/pgbackrest \
    && mkdir -p /etc/pgbackrest \
    && mkdir -p /etc/pgbackrest/conf.d \
    && touch /etc/pgbackrest/pgbackrest.conf \
    && chmod 640 /etc/pgbackrest/pgbackrest.conf \
    && chown postgres:postgres /etc/pgbackrest/pgbackrest.conf \
\ 
    # 外部表扩展tds_fdw
    && curl -sSL -o /tmp/tds_fdw-2.0.2.tar.gz https://github.com/tds-fdw/tds_fdw/archive/v2.0.2.tar.gz \
    && tar -xzf /tmp/tds_fdw-2.0.2.tar.gz -C /tmp/  \
    && cd /tmp/tds_fdw-2.0.2 \
    && apt-get install -y libsybdb5 freetds-dev freetds-common \
    && make USE_PGXS=1 && make USE_PGXS=1 install \
    && rm -rf /tmp/tds_fdw-2.0.2* \
    && apt-get purge -y libsybdb5 freetds-dev freetds-common \
\
    # 移除已无效的安装包
    && apt-get purge -y postgresql-server-dev-$PG_MAJOR python3-pip python3-wheel gcc python3-dev \
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /root/.cache

WORKDIR $PGHOME

# 定义数据目录，并赋权
RUN mkdir -p ./data /data ./.config/patroni \
    && chown -R postgres:postgres ./data /data \
    && chmod -R 700 ./data /data \
    && sed -i "s|/var/lib/postgresql.*|$PGHOME:/bin/bash|" /etc/passwd

# 默认配置文件载入
COPY patronictl.yml ./.config/patroni/patronictl.yaml
COPY entrypoint.sh .

ENV PGDATA=$PGHOME/data

USER postgres
EXPOSE 5432 8008
ENTRYPOINT ["/bin/bash", "entrypoint.sh"]
