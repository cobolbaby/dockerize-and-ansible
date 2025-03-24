ARG PG_VERSION=12.15

FROM harbor.itc.inventec.net/proxy/postgres:${PG_VERSION}-bookworm
LABEL maintainer="Zhang.Xing-Long@inventec.com"

ARG PGHOME=/home/postgres

RUN export DEBIAN_FRONTEND=noninteractive \
    # echo -e 会报 E: Syntax error /etc/apt/apt.conf.d/01norecommend:1: Extra junk after value
    && echo 'APT::Install-Recommends "0";\nAPT::Install-Suggests "0";' > /etc/apt/apt.conf.d/01norecommend \
    && apt-get update \
    # 通用包
    && apt-get install -y vim-tiny curl jq pigz net-tools unzip procps wget --fix-missing \
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /root/.cache

# 扩展安装需要依赖postgresql-server-dev-${PG_MAJOR}/make/gcc
# patroni包下载需要依赖pip
# tds_fdw需要从github下载最新版代码，依赖git
# 用于编译的包，最后会被清理掉
RUN apt-get update \
    && apt-get install -y postgresql-server-dev-${PG_MAJOR} make gcc python3-pip --fix-missing \
\
    # 安装Patroni
    && pip3 install --break-system-packages psycopg2-binary \
    && pip3 install --break-system-packages patroni[etcd] \
\
    # 分区表管理工具
    && apt-get install -y postgresql-${PG_MAJOR}-partman \
\
    # 表，索引在线重建工具 https://pgxn.org/dist/pg_repack/
    && apt-get install -y postgresql-${PG_MAJOR}-repack \
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
    # TODO:Babelfish
    # 外部表扩展 - tds_fdw
    && curl -sSL -o /tmp/tds_fdw-master.zip https://github.com/tds-fdw/tds_fdw/archive/refs/heads/master.zip \
    && unzip /tmp/tds_fdw-master.zip -d /tmp/ \
    && cd /tmp/tds_fdw-master \
    && apt-get install -y libsybdb5 freetds-dev freetds-common \
    && make USE_PGXS=1 && make USE_PGXS=1 install \
    && rm -rf /tmp/tds_fdw-master* \
    # ERROR:  could not load library "/usr/lib/postgresql/12/lib/tds_fdw.so": libsybdb.so.5: cannot open shared object file: No such file or directory
    # && apt-get purge -y libsybdb5 freetds-dev freetds-common \
\
    # 外部表扩展 - mongo_fdw
    && apt-get install -y cmake pkg-config \
    && curl -sSL -o /tmp/mongo_fdw-REL-5_5_2.tar.gz https://github.com/EnterpriseDB/mongo_fdw/archive/refs/tags/REL-5_5_2.tar.gz \
    && tar -xzf /tmp/mongo_fdw-REL-5_5_2.tar.gz -C /tmp/  \
    && cd /tmp/mongo_fdw-REL-5_5_2 \
    && ./autogen.sh \
    && export MONGO_FDW_SOURCE_DIR=/tmp/mongo_fdw-REL-5_5_2 \
    && export PKG_CONFIG_PATH=$MONGO_FDW_SOURCE_DIR/mongo-c-driver/src/libmongoc/src:$MONGO_FDW_SOURCE_DIR/mongo-c-driver/src/libbson/src \
    && make USE_PGXS=1 && make USE_PGXS=1 install \
    && rm -rf /tmp/mongo_fdw-REL-5_5_2* \
    # && apt-get purge -y cmake pkg-config \
\
    # 添加S3备份所需必要的命令 - mc
    # https://docs.min.io/docs/minio-client-quickstart-guide.html
    && curl https://dl.min.io/client/mc/release/linux-amd64/mc -o /usr/local/bin/mc \
    && chmod +x /usr/local/bin/mc \
\
    # pg_cron
    && apt-get install -y postgresql-${PG_MAJOR}-cron \
\
    # pldebugger
    && apt-get install -y postgresql-${PG_MAJOR}-pldebugger \
\
    # pg_show_plan
\
    # pg_hint_plan
    && apt-get install -y postgresql-${PG_MAJOR}-pg-hint-plan \
\
    # rsync
    && apt-get install -y rsync \
\
    # pgbadger
    # If you plan to parse PostgreSQL CSV log files, you might need some Perl Modules: Text::CSV_XS
    # If you want to export statistics as JSON file, you need an additional Perl module: JSON::XS
    && apt-get install -y perl libtext-csv-xs-perl libjson-xs-perl \
    && curl -sSL -o /tmp/pgbadger-master.zip https://github.com/darold/pgbadger/archive/refs/heads/master.zip \
    && unzip /tmp/pgbadger-master.zip -d /tmp/ \
    && cd /tmp/pgbadger-master/ \
    && perl Makefile.PL \
    && make && make install \
    && rm -rf /tmp/pgbadger-master* \
\
    # influxdb_fdw
    && apt-get install -y cmake g++ libcurl4-openssl-dev \
    && curl -sSL -o /tmp/influxdb-cxx-main.zip https://github.com/pgspider/influxdb-cxx/archive/refs/heads/main.zip \
    && unzip /tmp/influxdb-cxx-main.zip -d /tmp/ \
    && cd /tmp/influxdb-cxx-main && mkdir build && cd build \
    && cmake .. -DINFLUXCXX_WITH_BOOST=OFF -DINFLUXCXX_TESTING=OFF \
    && make install \
    && curl -sSL -o /tmp/influxdb_fdw-master.zip https://github.com/pgspider/influxdb_fdw/archive/refs/heads/master.zip \
    && unzip /tmp/influxdb_fdw-master.zip -d /tmp/ \
    && cd /tmp/influxdb_fdw-master \
    && make USE_PGXS=1 with_llvm=no CXX_CLIENT=1 \
    && make install USE_PGXS=1 with_llvm=no CXX_CLIENT=1 \
    && rm -rf /tmp/influxdb-cxx-main* /tmp/influxdb_fdw-master* \
    # && apt-get purge -y cmake g++ \
\
    # citus
    # TODO: citus 不支持 arm 架构
    && curl -sSL https://install.citusdata.com/community/deb.sh | bash \
    && apt-get install -y postgresql-${PG_MAJOR}-citus-12.1 \
\
    # pgvector 支持向量运算
    && apt-get install -y postgresql-${PG_MAJOR}-pgvector \
\
    # TODO:oracle_fdw
    # && apt-get install -y postgresql-${PG_MAJOR}-oracle-fdw \
\
    # TODO:mysql_fdw
    # && apt-get install -y postgresql-${PG_MAJOR}-mysql_fdw \
\
    # pg_jieba
    && apt-get install -y cmake g++ git \
    && cd /tmp/ && git clone --depth 1 https://github.com/jaiminpan/pg_jieba \
    && cd pg_jieba && git submodule update --init --recursive \
    && mkdir build && cd build && cmake -DPostgreSQL_TYPE_INCLUDE_DIR=/usr/include/postgresql/${PG_MAJOR}/server .. \
    && make && make install \
    && rm -rf /tmp/pg_jieba \
    # && apt-get purge -y cmake g++ git \
\
    # pg_dirtyread
    && apt-get install -y postgresql-${PG_MAJOR}-dirtyread \
\
    # Javascript 执行引擎 https://github.com/plv8/plv8
    # 源码编译耗时 30min+，需要做足心理准备
    # https://github.com/plv8/plv8/blob/r3.2/platforms/Docker/bullseye/14.5/Dockerfile
    # && apt-get install -y libtinfo5 build-essential pkg-config libstdc++-10-dev cmake git \
    # && export PLV8_BRANCH=r3.2 \
    # && export PLV8_VERSION=3.2.2 \
    # && cd /tmp/ && git clone --branch ${PLV8_BRANCH} --single-branch --depth 1 https://github.com/plv8/plv8 \
    # && cd plv8 \
    # && make install \
    # && strip /usr/lib/postgresql/${PG_MAJOR}/lib/plv8-${PLV8_VERSION}.so \
    # && rm -rf /tmp/plv8 \
\
    # PL/Python — Python Procedural Language
    # apt-cache search ".*plpython3.*"
    && apt-get install -y postgresql-plpython3-${PG_MAJOR} \
\    
    # Timescaledb
    # 官方源的包只包含部分功能
    # && apt-get install -y postgresql-${PG_MAJOR}-timescaledb \
    # fix: could not access file "$libdir/timescaledb-tsl-2.17.2": No such file or directory
    && apt-get install -y lsb-release \
    && echo "deb https://packagecloud.io/timescale/timescaledb/debian/ $(lsb_release -c -s) main" | tee /etc/apt/sources.list.d/timescaledb.list \
    && wget --quiet -O - https://packagecloud.io/timescale/timescaledb/gpgkey | gpg --dearmor -o /etc/apt/trusted.gpg.d/timescaledb.gpg \
    && apt-get update \
    && apt-get install -y timescaledb-2-postgresql-${PG_MAJOR} \
\
    # pg_ivm
    && curl -sSL -o /tmp/pg_ivm-1.9.tar.gz https://github.com/sraoss/pg_ivm/archive/refs/tags/v1.9.tar.gz \
    && tar -xzf /tmp/pg_ivm-1.9.tar.gz -C /tmp \
    && cd /tmp/pg_ivm-1.9 \
    && make install \
    && rm -rf /tmp/pg_ivm-1.9* \
\
    # pg_analytics
    && curl -sSL -o /tmp/postgresql-16-pg-analytics_0.2.4-1PARADEDB-bookworm_amd64.deb https://github.com/paradedb/pg_analytics/releases/download/v0.2.4/postgresql-16-pg-analytics_0.2.4-1PARADEDB-bookworm_amd64.deb \
    && dpkg -i /tmp/postgresql-16-pg-analytics_0.2.4-1PARADEDB-bookworm_amd64.deb \
    && rm -rf /tmp/postgresql-16-pg-analytics_0.2.4-1PARADEDB-bookworm_amd64.deb \
    # https://github.com/paradedb/paradedb/blob/dev/docker/Dockerfile
\
    # pgcopydb
    && apt-get install -y pgcopydb \
\
    # 支持 LDAP
    && apt-get install -y ldap-utils \
\
    # 支持 pg_duckdb
    && apt-get install -y git cmake g++ liblz4-dev ninja-build \
    && cd /tmp/ && git clone --depth 1 https://github.com/duckdb/pg_duckdb.git \
    && cd pg_duckdb \
    && make install \
    && rm -rf /tmp/pg_duckdb \
\
    # 移除已无效的安装包
    && apt-get purge -y postgresql-server-dev-${PG_MAJOR} make gcc cmake g++ git \
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /root/.cache

# 上一步执行完 autoremove -y 之后，yaml 包就被删除了，这里重新添加
# fix: ModuleNotFoundError: No module named 'yaml'
RUN pip3 install --break-system-packages PyYAML

WORKDIR $PGHOME

# 定义数据目录，并赋权
RUN mkdir -p ./data /data ./.config/patroni \
    && touch .psql_history \
    && chown -R postgres:postgres $PGHOME /data \
    && chmod -R 700 $PGHOME/data /data \
    && sed -i "s|/var/lib/postgresql.*|$PGHOME:/bin/bash|" /etc/passwd

ENV PGDATA=$PGHOME/data

# pgbackrest 要求 PG 节点间 SSH 免密
RUN apt-get update \
    && apt-get install -y openssh-client openssh-server sudo \
    # fix: /etc/ssh/ssh_host_rsa_key already exists
    # && ssh-keygen -t rsa -N '' -f /etc/ssh/ssh_host_rsa_key \
    # && ssh-keygen -t ecdsa -N '' -f /etc/ssh/ssh_host_ecdsa_key \
    # && ssh-keygen -t ed25519 -N '' -f /etc/ssh/ssh_host_ed25519_key \
    && echo 'postgres ALL=(ALL) NOPASSWD:/usr/sbin/sshd' >> /etc/sudoers \
    # fix: Missing privilege separation directory: /run/sshd
    && mkdir -p /run/sshd \
    && mkdir -p /home/postgres/.ssh \
    && ssh-keygen -t rsa -N '' -f /home/postgres/.ssh/id_rsa \
    && cat /home/postgres/.ssh/id_rsa.pub >> /home/postgres/.ssh/authorized_keys \
    && chown -R postgres:postgres /home/postgres/.ssh \
    && chmod 700 /home/postgres/.ssh \
    && chmod 600 /home/postgres/.ssh/authorized_keys \
    # ssh容器互访时，不用输入yes
    && sed -i 's/^#   StrictHostKeyChecking ask$/    StrictHostKeyChecking no/g' /etc/ssh/ssh_config \
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /root/.cache

# 支持 PL/Python 高级用法
RUN pip3 install --break-system-packages numpy

# 默认配置文件载入
COPY config/* ./.config/patroni/
COPY bin/* ./
RUN chmod +x *.sh

# jieba 自定义字典
COPY dict/jieba_user.dict /usr/share/postgresql/16/tsearch_data/

USER postgres
EXPOSE 5432 8008
ENTRYPOINT ["/bin/bash", "entrypoint.sh"]
