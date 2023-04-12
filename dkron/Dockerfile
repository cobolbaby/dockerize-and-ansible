ARG OPENJDK_VERSION
FROM registry.inventec/proxy/library/openjdk:${OPENJDK_VERSION}
LABEL maintainer="Zhang.Xing-Long@inventec.com"

ARG PG_VERSION=12
ARG DOCKER_VERSION=19.03.15
ARG DKRON_VERSION

ENV SHELL /bin/bash
ENV LANG C.UTF-8

# 通用配置
RUN export DEBIAN_FRONTEND=noninteractive \
    && echo 'APT::Install-Recommends "0";\nAPT::Install-Suggests "0";' > /etc/apt/apt.conf.d/01norecommend \
    && apt-get update -y \
    # 通用包
    && apt-get install -y vim-tiny curl jq pigz net-tools unzip procps --fix-missing \
    && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo 'Asia/Shanghai' > /etc/timezone
    
RUN apt-get install -y wget gnupg lsb-release && \
    # PG https://www.postgresql.org/download/linux/ubuntu/
    sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list' && \
    wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - && \
    apt-get update && \
    apt-get -y install postgresql-client-${PG_VERSION} && \
\
    # 添加S3备份所需必要的命令 - mc
    # https://docs.min.io/docs/minio-client-quickstart-guide.html
    wget https://dl.min.io/client/mc/release/linux-amd64/mc -P /usr/local/bin/ && \
    chmod +x /usr/local/bin/mc && \
\
    # 添加 Python 环境
    apt-get -y install -y python3 python3-pip && \
    pip3 install --upgrade pip && \
\    
    # Docker https://docs.docker.com/engine/install/debian/
    apt-get update && \
    apt-get install -y ca-certificates curl gnupg && \
    mkdir -m 0755 -p /etc/apt/keyrings && \
    curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg && \
    echo \
    "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian \
    "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
    tee /etc/apt/sources.list.d/docker.list > /dev/null && \
    apt-get update && \
    apt-get install -y docker-ce-cli=$(apt-cache madison docker-ce | awk '{ print $3 }' | grep $DOCKER_VERSION) && \
\
    # 添加分布式任务管理组件 - Dkron
    mkdir -p /opt/dkron && \
    cd /opt/dkron && \
    wget -O dkron.tar.gz https://github.com/distribworks/dkron/releases/download/v${DKRON_VERSION}/dkron_${DKRON_VERSION}_linux_amd64.tar.gz && \
    tar -zxvf dkron.tar.gz && \
    rm *.tar.gz && \
\
    # Cleaner
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /root/.cache

WORKDIR /opt/dkron-resource

COPY requirements.txt .
RUN pip3 install --no-cache-dir -r requirements.txt

WORKDIR /opt/dkron
ENTRYPOINT ["/opt/dkron/dkron"]
CMD ["--help"]
