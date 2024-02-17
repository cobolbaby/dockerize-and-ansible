ARG PG_VERSION=12.15

# fix: 不能使用最新的 12.15, 12, 12.15-bookworm, 12-bookworm 版本，回退到 12.15-bullseye, 12-bullseye
# 执行 apt-get update 会看到如下报错
# Reading package lists... Done
# E: Problem executing scripts APT::Update::Post-Invoke 'rm -f /var/cache/apt/archives/*.deb /var/cache/apt/archives/partial/*.deb /var/cache/apt/*.bin || true'
# E: Sub-process returned an error code
FROM registry.inventec/proxy/library/postgres:${PG_VERSION}-bullseye
LABEL maintainer="Zhang.Xing-Long@inventec.com"

ARG PGHOME=/home/postgres

RUN export DEBIAN_FRONTEND=noninteractive \
    && echo 'APT::Install-Recommends "0";\nAPT::Install-Suggests "0";' > /etc/apt/apt.conf.d/01norecommend \
    && apt-get update \
    # 通用包
    && apt-get install -y vim-tiny curl jq pigz net-tools unzip procps wget --fix-missing \
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /root/.cache

# 扩展安装需要依赖postgresql-server-dev-${PG_MAJOR}/make/gcc
# patroni包下载需要依赖pip，编译的时候需要依赖wheel/gcc/python3-dev
# tds_fdw需要从github下载最新版代码，依赖git
# 用于编译的包，最后会被清理掉
RUN apt-get update \
    && apt-get install -y postgresql-server-dev-${PG_MAJOR} make gcc python3-pip python3-wheel python3-dev --fix-missing \
\
    # 安装Patroni
    && pip3 install setuptools \
    && pip3 install psycopg2-binary \
    && pip3 install patroni[etcd,raft] \
    # 卸载以后执行patroni会报: No matching distribution found for pkg_resources
    # && pip3 uninstall -y setuptools \
\
    # 分区表管理工具
    && curl -sSL -o /tmp/pg_partman-4.7.4.tar.gz https://github.com/pgpartman/pg_partman/archive/refs/tags/v4.7.4.tar.gz \
    && tar -xzf /tmp/pg_partman-4.7.4.tar.gz -C /tmp/  \
    && cd /tmp/pg_partman-4.7.4 \
    # && make install \
    && make NO_BGW=1 install \
    && rm -rf /tmp/pg_partman-4.7.4* \
\
    # 表，索引在线重建工具 https://pgxn.org/dist/pg_repack/
    && curl -sSL -o /tmp/pg_repack-1.5.0.zip https://api.pgxn.org/dist/pg_repack/1.5.0/pg_repack-1.5.0.zip \
    && unzip /tmp/pg_repack-1.5.0.zip -d /tmp/ \
    && cd /tmp/pg_repack-1.5.0 \
    && apt-get install -y libssl-dev zlib1g-dev \
    && make && make install \
    && rm -rf /tmp/pg_repack-1.5.0* \
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
    && curl -sSL -o /tmp/mongo_fdw-REL-5_5_1.tar.gz https://github.com/EnterpriseDB/mongo_fdw/archive/refs/tags/REL-5_5_1.tar.gz \
    && tar -xzf /tmp/mongo_fdw-REL-5_5_1.tar.gz -C /tmp/  \
    && cd /tmp/mongo_fdw-REL-5_5_1 \
    && ./autogen.sh --with-master \
    && export MONGO_FDW_SOURCE_DIR=/tmp/mongo_fdw-REL-5_5_1 \
    && export PKG_CONFIG_PATH=$MONGO_FDW_SOURCE_DIR/mongo-c-driver/src/libmongoc/src:$MONGO_FDW_SOURCE_DIR/mongo-c-driver/src/libbson/src \
    && make USE_PGXS=1 && make USE_PGXS=1 install \
    && rm -rf /tmp/mongo_fdw-REL-5_5_1* \
    # && apt-get purge -y cmake pkg-config \
\
    # 添加S3备份所需必要的命令 - mc
    # https://docs.min.io/docs/minio-client-quickstart-guide.html
    && curl https://dl.min.io/client/mc/release/linux-amd64/mc -o /usr/local/bin/mc \
    && chmod +x /usr/local/bin/mc \
\
    # pg_cron
    && apt-get -y install postgresql-${PG_MAJOR}-cron \
\
    # pldebugger
    && apt-get -y install postgresql-${PG_MAJOR}-pldebugger \
\
    # pg_show_plan
\
    # pg_hint_plan
    && curl -sSL -o /tmp/pg_hint_plan-REL16_1_6_0.tar.gz https://github.com/ossc-db/pg_hint_plan/archive/refs/tags/REL16_1_6_0.tar.gz \
    && tar -xzf /tmp/pg_hint_plan-REL16_1_6_0.tar.gz -C /tmp/  \
    && cd /tmp/pg_hint_plan-REL16_1_6_0 \
    && make && make install \
    && rm -rf /tmp/pg_hint_plan-REL16_1_6_0* \
\
    # rsync
    && apt-get install -y rsync \
\
    # pgbadger
    # If you plan to parse PostgreSQL CSV log files, you might need some Perl Modules: Text::CSV_XS
    # If you want to export statistics as JSON file, you need an additional Perl module: JSON::XS
    && apt-get install -y perl libtext-csv-xs-perl libjson-xs-perl \
    && curl -sSL -o /tmp/pgbadger-12.4.tar.gz https://github.com/darold/pgbadger/archive/refs/tags/v12.4.tar.gz \
    && tar -xzf /tmp/pgbadger-12.4.tar.gz -C /tmp/ \
    && cd /tmp/pgbadger-12.4/ \
    && perl Makefile.PL \
    && make && make install \
    && rm -rf /tmp/pgbadger-12.4* \
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
    # pgAudit 目前有点鸡肋，因为只能从日志文件中看到相关的审计日志
    # && apt-get install -y libkrb5-dev \
    # && curl -sSL -o /tmp/pgaudit-1.4.3.tar.gz https://github.com/pgaudit/pgaudit/archive/refs/tags/1.4.3.tar.gz \
    # && tar -xzf /tmp/pgaudit-1.4.3.tar.gz -C /tmp/ \
    # && cd /tmp/pgaudit-1.4.3 \
    # && make install USE_PGXS=1 \
    # && rm -rf /tmp/pgaudit-1.4.3* \
\
    # citus
    && curl -sSL https://install.citusdata.com/community/deb.sh | bash \
    && apt-get -y install postgresql-${PG_MAJOR}-citus-12.1 \
\
    # pgvector 支持向量运算
    && curl -sSL -o /tmp/pgvector-0.6.0.tar.gz https://github.com/pgvector/pgvector/archive/refs/tags/v0.6.0.tar.gz \
    && tar -xzf /tmp/pgvector-0.6.0.tar.gz -C /tmp/ \
    && cd /tmp/pgvector-0.6.0/ \
    && make && make install \
    && rm -rf /tmp/pgvector-0.6.0* \
\
    # TODO:oracle_fdw
    # && curl -sSL -o /tmp/oracle_fdw-ORACLE_FDW_2_5_0.tar.gz https://github.com/laurenz/oracle_fdw/archive/refs/tags/ORACLE_FDW_2_5_0.tar.gz \
    # && tar -xzf /tmp/oracle_fdw-ORACLE_FDW_2_5_0.tar.gz -C /tmp/ \
    # && cd /tmp/oracle_fdw-ORACLE_FDW_2_5_0 \
    # && make && make install \
    # oracle_utils.c:22:10: fatal error: oci.h: No such file or directory
    # && rm -rf /tmp/oracle_fdw-ORACLE_FDW_2_5_0* \
\
    # TODO:mysql_fdw
    # TODO:plpgsql_check
    # TODO:MADlib 2.0.0
    # pg_jieba
    && apt-get install -y cmake g++ git \
    && cd /tmp/ && git clone --depth 1 https://github.com/jaiminpan/pg_jieba \
    && cd pg_jieba && git submodule update --init --recursive \
    && mkdir build && cd build && cmake .. \
    && make && make install \
    && rm -rf /tmp/pg_jieba \
    # && apt-get purge -y git \
\
    # pg_dirtyread
    && curl -sSL -o /tmp/pg_dirtyread-2.6.tar.gz https://github.com/df7cb/pg_dirtyread/archive/refs/tags/2.6.tar.gz \
    && tar -xzf /tmp/pg_dirtyread-2.6.tar.gz -C /tmp/ \
    && cd /tmp/pg_dirtyread-2.6 \
    && make && make install \
    && rm -rf /tmp/pg_dirtyread-2.6* \
\
    # Javascript 执行引擎 https://github.com/plv8/plv8
    # 源码编译耗时 30min+，需要做足心理准备
    # https://github.com/plv8/plv8/blob/r3.2/platforms/Docker/bullseye/14.5/Dockerfile
    # && apt-get install -y build-essential git postgresql-server-dev-${PG_MAJOR} libtinfo5 pkg-config clang binutils libstdc++-10-dev cmake \
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
    && apt-get -y install postgresql-plpython3-${PG_MAJOR} \
\
    # 移除已无效的安装包
    && apt-get purge -y postgresql-server-dev-${PG_MAJOR} make gcc cmake g++ git \
    && apt-get autoremove -y \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /root/.cache

# 上一步执行完 autoremove -y 之后，yaml 包就被删除了，这里重新添加
# fix: ModuleNotFoundError: No module named 'yaml'
RUN pip3 install PyYAML

WORKDIR $PGHOME

# 定义数据目录，并赋权
RUN mkdir -p ./data /data ./.config/patroni /raft/datadir \
    && touch .psql_history \
    && chown -R postgres:postgres $PGHOME /data \
    && chmod -R 700 $PGHOME/data /data /raft/datadir \
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
RUN pip3 install numpy

# 默认配置文件载入
COPY config/* ./.config/patroni/
COPY bin/* ./
RUN chmod +x *.sh

USER postgres
EXPOSE 5432 8008
ENTRYPOINT ["/bin/bash", "entrypoint.sh"]
