FROM maven:3.6-openjdk-8 as maven
WORKDIR /app
COPY pom.xml .
RUN mvn dependency:copy-dependencies -DoutputDirectory=jars

FROM centos:7
LABEL maintainer="Zhang.Xing-Long@inventec.com"

ARG TMP_DIR=/tmp/spark
COPY pkgs/* ${TMP_DIR}/

WORKDIR /opt/spark

RUN cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo 'Asia/Shanghai' > /etc/timezone \
    # && mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup \
    # && curl -so /etc/yum.repos.d/CentOS-Base.repo http://mirrors.163.com/.help/CentOS7-Base-163.repo \
    && yum install -y net-tools java-1.8.0-openjdk \
    && yum clean all \
    && tar -zxvf ${TMP_DIR}/spark-2.3.3-bin-hadoop2.7.tgz -C . --strip-components=1 \
    && rm -rf ${TMP_DIR}

ENV LANG=en_US.UTF-8 \
    SPARK_HOME=/opt/spark \
    PATH=${PATH}:${SPARK_HOME}/bin

COPY entrypoint.sh .
COPY conf/* ./conf/
COPY --from=maven /app/jars/* ./jars/

EXPOSE 4040 6066 7077 8080 8081
ENTRYPOINT [ "./entrypoint.sh" ]
CMD ["/bin/bash"]
