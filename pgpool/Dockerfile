FROM registry.inventec/proxy/pgpool/pgpool:4.2.6

WORKDIR /opt/confd/bin/

USER root

# wget 下载完之后文件大小为 0，跳过下载
# RUN wget -O /usr/local/bin/confd https://github.com/kelseyhightower/confd/releases/download/v0.16.0/confd-0.16.0-linux-amd64 \
#     && chmod +x /usr/local/bin/confd \
#     && wget -O /usr/local/bin/dumb-init https://github.com/Yelp/dumb-init/releases/download/v1.2.5/dumb-init_1.2.5_x86_64 \
#     && chmod +x /usr/local/bin/dumb-init

ENV PGPOOL_CONF_VOLUME=/config \
    PATH="/opt/confd/bin:$PGPOOL_INSTALL_DIR/bin:$PATH"

COPY config/pgpool ${PGPOOL_INSTALL_DIR}/etc/
COPY config/confd /etc/confd
COPY bin /opt/confd/bin

# 一定要留意 pgpool.conf 的权限问题
RUN chown -R postgres:postgres /etc/confd /opt/confd ${PGPOOL_INSTALL_DIR} \
    && chmod +x /opt/confd/bin/* \
    && chmod -R 644 ${PGPOOL_INSTALL_DIR}/etc/*

USER postgres

ENTRYPOINT [ "/opt/confd/bin/entrypoint.sh" ]
