FROM centos:7
LABEL maintainer="Zhang.Xing-Long@inventec.com"

ARG DKRON_VERSION

RUN cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo 'Asia/Shanghai' > /etc/timezone \
    # && mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup \
    # && curl -so /etc/yum.repos.d/CentOS-Base.repo http://mirrors.163.com/.help/CentOS7-Base-163.repo \
    && yum install -y net-tools \
    && yum clean all \
    && mkdir -p /opt/local/dkron \
    && cd /opt/local/dkron \
    && curl -sSL -o dkron.tar.gz https://github.com/distribworks/dkron/releases/download/v${DKRON_VERSION}/dkron_${DKRON_VERSION}_linux_amd64.tar.gz \
    && tar -xzf dkron.tar.gz \
    && rm dkron.tar.gz
    # && 安装Docker

EXPOSE 8080 8946

ENV SHELL /bin/bash
ENV LANG en_US.UTF-8
WORKDIR /opt/local/dkron

ENTRYPOINT ["/opt/local/dkron/dkron"]
CMD ["--help"]
