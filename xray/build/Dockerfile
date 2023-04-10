ARG NGINX_VERSION

FROM nginx:${NGINX_VERSION}

ARG XRAY_VERSION

RUN apt-get update && \
    apt-get install -y \
    procps net-tools curl wget unzip jq vim

# 安装 TLS 证书 https://certbot.eff.org/instructions?ws=nginx&os=pip
RUN apt-get update && \
    apt-get install -y python3 python3-venv libaugeas0 && \
    python3 -m venv /opt/certbot/ && \
    /opt/certbot/bin/pip install --upgrade pip && \
    /opt/certbot/bin/pip install certbot certbot-nginx && \
    ln -s /opt/certbot/bin/certbot /usr/bin/certbot

WORKDIR /opt/xray

RUN wget -O x.zip https://github.com/XTLS/Xray-core/releases/download/${XRAY_VERSION}/Xray-linux-64.zip && \
    unzip x.zip && rm -rf x.zip && \
    chmod +x xray && \
    mkdir -p /var/log/xray /usr/share/xray && \
    wget -O /usr/share/xray/geosite.dat https://github.com/v2fly/domain-list-community/releases/latest/download/dlc.dat && \
    wget -O /usr/share/xray/geoip.dat https://github.com/v2fly/geoip/releases/latest/download/geoip.dat

COPY conf/xray/config_server.json /opt/xray/config.json
COPY conf/nginx/* /etc/nginx/conf.d/
COPY entrypoint.sh /

ENV PATH $PATH:/opt/xray

ENTRYPOINT ["/entrypoint.sh"]
