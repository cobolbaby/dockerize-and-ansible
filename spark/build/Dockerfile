FROM centos:7
LABEL maintainer="Zhang.Xing-Long@inventec.com"

ARG TMP_DIR=/tmp/spark
COPY pkgs/* ${TMP_DIR}/

RUN cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo 'Asia/Shanghai' > /etc/timezone \
    # && mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup \
    # && curl -so /etc/yum.repos.d/CentOS-Base.repo http://mirrors.163.com/.help/CentOS7-Base-163.repo \
    && yum install -y net-tools \
    && yum clean all \
    && mkdir -p /opt/jdk /opt/spark \
    && tar -zxvf ${TMP_DIR}/jdk-8u171-linux-x64.tar.gz -C /opt/jdk --strip-components=1 \
    && tar -zxvf ${TMP_DIR}/spark-2.3.3-bin-hadoop2.7.tgz -C /opt/spark --strip-components=1 \
    && rm -rf ${TMP_DIR}

ENV LANG en_US.UTF-8
ENV JAVA_HOME /opt/jdk
ENV SPARK_HOME /opt/spark
ENV PATH ${PATH}:${JAVA_HOME}/bin:${SPARK_HOME}/bin

WORKDIR /opt/spark
COPY entrypoint.sh .
COPY jars/*.jar ./jars/
COPY conf/* ./conf/

EXPOSE 4040 6066 7077 8080 8081
ENTRYPOINT [ "./entrypoint.sh" ]
CMD ["/bin/bash"]