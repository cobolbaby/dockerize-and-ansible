FROM centos:7
LABEL maintainer="Zhang.Xing-Long@inventec.com"

ARG DOCKER_VERSION=18.06.3.ce
ARG DKRON_VERSION=1.2.5

RUN cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo 'Asia/Shanghai' > /etc/timezone \
    && curl -sSL -o docker-ce-${DOCKER_VERSION}-3.el7.x86_64.rpm https://download.docker.com/linux/centos/7/x86_64/stable/Packages/docker-ce-${DOCKER_VERSION}-3.el7.x86_64.rpm \
    && yum install -y docker-ce-${DOCKER_VERSION}-3.el7.x86_64.rpm net-tools \
    && yum clean all \
    && mkdir -p /opt/local/dkron \
    && cd /opt/local/dkron \
    && curl -sSL -o dkron.tar.gz https://github.com/distribworks/dkron/releases/download/v${DKRON_VERSION}/dkron_${DKRON_VERSION}_linux_amd64.tar.gz \
    && tar -xzf dkron.tar.gz \
    && rm *.tar.gz *.rpm

EXPOSE 8080 8946

ENV SHELL /bin/bash
ENV LANG en_US.UTF-8
WORKDIR /opt/local/dkron

ENTRYPOINT ["/opt/local/dkron/dkron"]
CMD ["--help"]
