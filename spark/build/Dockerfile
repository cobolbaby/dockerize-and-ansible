FROM centos:7

ARG TMP_DIR=/tmp/spark
COPY pkgs/* ${TMP_DIR}/

RUN cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo 'Asia/Shanghai' > /etc/timezone \
    && tar -zxvf ${TMP_DIR}/jdk-8u171-linux-x64.tar.gz -C /opt \
    && ln -s /opt/jdk1.8.0_171 /opt/jdk \
    && tar -zxvf ${TMP_DIR}/spark-2.3.0-bin-hadoop2.7.tgz -C /opt \
    && ln -s /opt/spark-2.3.0-bin-hadoop2.7 /opt/spark \
    && rm -rf ${TMP_DIR}

ENV JAVA_HOME /opt/jdk
ENV SPARK_HOME /opt/spark
ENV PATH ${PATH}:${JAVA_HOME}/bin:${SPARK_HOME}/bin

WORKDIR /opt/spark
EXPOSE 6066 7077 8080 8081 4044
CMD ["/bin/bash"]