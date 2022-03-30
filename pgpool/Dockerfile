FROM pgpool/pgpool:4.2.6

WORKDIR /opt/confd/bin/

# 安装 Confd
RUN wget https://github.com/kelseyhightower/confd/releases/download/v0.16.0/confd-0.16.0-linux-amd64 \
    && mv confd-0.16.0-linux-amd64 /opt/confd/bin/confd \
    && chmod +x /opt/confd/bin/confd

ENV PGPOOL_CONF_VOLUME=/config \
    PATH="/opt/confd/bin:$PGPOOL_INSTALL_DIR/bin:$PATH"

COPY config/pgpool /config
COPY config/confd/conf.d/haproxy.toml /etc/confd/conf.d/
COPY config/confd/templates/haproxy.tmpl /etc/confd/templates/

COPY bin/start-all.sh ${PGPOOL_INSTALL_DIR}/bin/

CMD [ "/opt/pgpool-II/bin/start-all.sh" ]
