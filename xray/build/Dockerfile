ARG NGINX_VERSION=1.20

FROM nginx:${NGINX_VERSION}

ARG XRAY_VERSION=v1.7.5

RUN apt-get update && \
    apt-get install -y \
    procps net-tools curl wget unzip jq && \
    rm -rf /var/lib/apt/lists/*

# 安装 TLS 证书???
RUN apt-get install -y certbot

WORKDIR /opt/xray

RUN wget -O x.zip https://github.com/XTLS/Xray-core/releases/download/${XRAY_VERSION}/Xray-linux-64.zip && \
    unzip x.zip && rm -rf x.zip && \
    chmod +x xray && \
    mkdir -p /var/log/xray /usr/share/xray && \
    wget -O /usr/share/xray/geosite.dat https://github.com/v2fly/domain-list-community/releases/latest/download/dlc.dat && \
    wget -O /usr/share/xray/geoip.dat https://github.com/v2fly/geoip/releases/latest/download/geoip.dat

COPY conf/xray/config_server.json /opt/xray/config.json
COPY conf/nginx/* /etc/nginx/conf.d/

ENTRYPOINT ["./entrypoint.sh"]