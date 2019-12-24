ARG VERSION

FROM jenkins/jenkins:${VERSION}
LABEL maintainer="Zhang.Xing-Long@inventec.com"

USER root

RUN cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo 'Asia/Shanghai' > /etc/timezone \
    && yum install -y net-tools gcc automake autoconf libtool make libtool-ltdl \
    && yum clean all

USER jenkins

ENV LANG en_US.UTF-8
