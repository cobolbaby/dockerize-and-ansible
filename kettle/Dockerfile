FROM registry.inventec/proxy/maven:3.9-eclipse-temurin-11 AS builder

# 安装依赖工具
RUN apt-get update && apt-get install -y \
    git \
    zip \
    wget \
    && rm -rf /var/lib/apt/lists/*

COPY maven/settings-docker.xml /usr/share/maven/ref/

WORKDIR /workspace

ARG KETTLE_BRANCH=9.5

# clone parent-poms 并构建
RUN git clone --depth 1 --branch ${KETTLE_BRANCH} https://github.com/pentaho/maven-parent-poms.git && \
    cd maven-parent-poms && \
    mvn clean install -DskipTests

# clone kettle
RUN git clone --depth 1 --branch ${KETTLE_BRANCH} https://github.com/pentaho/pentaho-kettle.git && \
    cd pentaho-kettle && \
    mvn clean package -DskipTests

# # 阶段 2：构建最小运行时镜像
# FROM registry.inventec/proxy/openjdk:25-ea-11-jdk-slim AS runtime

# WORKDIR /opt

# COPY --from=builder /workspace/pentaho-kettle/assemblies/client/target/pdi-ce-*-SNAPSHOT.zip /opt/pdi-ce.zip

# RUN apt-get update && apt-get install -y unzip && unzip /opt/pdi-ce.zip -d /opt && rm /opt/pdi-ce.zip

# WORKDIR /opt/pdi/data-integration

# # 设置默认执行 kitchen（可更换为 spoon.sh 或 pan.sh）
# CMD ["./kitchen.sh"]
