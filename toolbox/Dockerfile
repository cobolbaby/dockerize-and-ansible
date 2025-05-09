FROM registry.inventec/proxy/ubuntu:22.04

RUN apt-get update -y && \
    apt-get install -y \
        # DNS
        dnsutils \
        # 测网络连通性，测返回结果
        curl jq wget \
        # 测 TCP 连接数
        net-tools \
        # 测流量
        tcpdump iftop \
        # iotop 分析磁盘IO
        sysstat iotop \
        # iperf3 测网络性能，是否有丢包
        iperf3 \
        # 压测工具，压 CPU
        stress \
        # 查看系统版本
        lsb-release \
        # 压缩工具
        unzip

# psql, pg_dump, pg_restore
# PG https://www.postgresql.org/download/linux/ubuntu/
RUN apt-get install -y gnupg postgresql-common && \
    /usr/share/postgresql-common/pgdg/apt.postgresql.org.sh -y && \
    apt-get install -y postgresql-client-16

# Golang 程序性能分析
ARG GO_VERSION
# RUN curl -sSL -o go${GO_VERSION}.tar.gz https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz && \
#     rm -rf /usr/local/go && tar -C /usr/local -xzf go${GO_VERSION}.tar.gz && \
#     rm go${GO_VERSION}.tar.gz
ADD pkgs/go${GO_VERSION}.linux-amd64.tar.gz /usr/local/
ENV PATH=${PATH}:/usr/local/go/bin
RUN apt-get install -y graphviz

# Java 堆内存分析，https://eclipse.dev/mat/download/
RUN apt-get install -y openjdk-17-jdk
ARG MAT_VERSION
COPY pkgs/MemoryAnalyzer-${MAT_VERSION}-linux.gtk.x86_64.zip /tmp/
RUN unzip /tmp/MemoryAnalyzer-${MAT_VERSION}-linux.gtk.x86_64.zip -d /opt/ && \
    rm /tmp/MemoryAnalyzer-${MAT_VERSION}-linux.gtk.x86_64.zip

# smartctl 查询磁盘状态
RUN apt-get install -y smartmontools && \
    # https://downloads.linux.hpe.com/SDR/project/mcp/
    echo "deb [signed-by=/usr/share/keyrings/hpePublicKey.gpg] https://downloads.linux.hpe.com/SDR/repo/mcp jammy/current non-free" > /etc/apt/sources.list.d/mcp.list && \
    curl https://downloads.linux.hpe.com/SDR/hpPublicKey2048_key1.pub | gpg --dearmor | tee -a /usr/share/keyrings/hpePublicKey.gpg > /dev/null && \
    curl https://downloads.linux.hpe.com/SDR/hpePublicKey2048_key1.pub | gpg --dearmor | tee -a /usr/share/keyrings/hpePublicKey.gpg > /dev/null && \
    curl https://downloads.linux.hpe.com/SDR/hpePublicKey2048_key2.pub | gpg --dearmor | tee -a /usr/share/keyrings/hpePublicKey.gpg > /dev/null && \
    apt-get update && \
    apt-get install -y ssacli ssaducli
COPY smart_report.sh /
RUN chmod +x /smart_report.sh
