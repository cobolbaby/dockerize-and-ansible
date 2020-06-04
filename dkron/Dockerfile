FROM centos:7
LABEL maintainer="Zhang.Xing-Long@inventec.com"

ARG DOCKER_VERSION=18.06.3.ce
ARG DKRON_VERSION=1.2.5
ARG S3CMD_VERSION=2.1.0

# RUN cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
#     && echo 'Asia/Shanghai' > /etc/timezone \
#     && curl -sSL -o docker-ce-${DOCKER_VERSION}-3.el7.x86_64.rpm https://download.docker.com/linux/centos/7/x86_64/stable/Packages/docker-ce-${DOCKER_VERSION}-3.el7.x86_64.rpm \
#     && yum install -y docker-ce-${DOCKER_VERSION}-3.el7.x86_64.rpm net-tools \
#     && yum clean all \
#     && mkdir -p /opt/local/dkron \
#     && cd /opt/local/dkron \
#     && curl -sSL -o dkron.tar.gz https://github.com/distribworks/dkron/releases/download/v${DKRON_VERSION}/dkron_${DKRON_VERSION}_linux_amd64.tar.gz \
#     && tar -xzf dkron.tar.gz \
#     && rm *.tar.gz *.rpm

COPY pkgs /tmp

RUN cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo 'Asia/Shanghai' > /etc/timezone \
    && yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm \
    && yum install -y https://download.docker.com/linux/centos/7/x86_64/stable/Packages/docker-ce-${DOCKER_VERSION}-3.el7.x86_64.rpm \
                      net-tools jq  \
\
    # 添加分布式任务管理组件 - Dkron
    && mkdir -p /opt/local/dkron \
    && cd /opt/local/dkron \
    && mv /tmp/dkron_${DKRON_VERSION}_linux_amd64.tar.gz dkron.tar.gz \
    && tar -zxvf dkron.tar.gz \
    && rm *.tar.gz \
\
    # # 添加S3备份所需必要的命令 - s3cmd
    && yum install -y python-pip \
    && pip install --upgrade pip \
    && pip install s3cmd \
\
    # 添加S3备份所需必要的命令 - mc
    && mkdir -p /opt/local/mc \
    && cd /opt/local/mc \
    && curl -sSL -o mc https://dl.min.io/client/mc/release/linux-amd64/mc \
    && chmod +x mc \
\
    && yum install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-7-x86_64/pgdg-redhat-repo-latest.noarch.rpm \
    && yum install -y postgresql10 \
    && yum clean all

EXPOSE 8080 8946

ENV SHELL /bin/bash
ENV LANG en_US.UTF-8
WORKDIR /opt/local/dkron

ENTRYPOINT ["/opt/local/dkron/dkron"]
CMD ["--help"]
