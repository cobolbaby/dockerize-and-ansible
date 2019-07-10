FROM centos:7
LABEL maintainer="Zhang.Xing-Long@inventec.com"

# Pack openjdk-8
# Ref: http://openjdk.java.net/install/
RUN cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo 'Asia/Shanghai' > /etc/timezone \
    && yum install -y net-tools java-1.8.0-openjdk \
    && yum clean all

COPY ./release /opt

WORKDIR /opt
ENTRYPOINT [ "./entrypoint.sh" ]