FROM registry.inventec/proxy/ubuntu:22.04

RUN apt-get update -y && \
    apt-get install -y \
        # 测网络连通性，测返回结果
        curl jq \
        # 测 TCP 连接数
        net-tools \
        # 测流量
        tcpdump iftop \
        # iotop 分析磁盘IO
        sysstat iotop \
        # iperf3 测网络性能，是否有丢包
        iperf3 \
        # 压测工具，压 CPU
        stress && \
    # psql, pg_dump, pg_restore
    # PG https://www.postgresql.org/download/linux/ubuntu/
    apt-get install -y wget gnupg lsb-release && \
    sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list' && \
    wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add - && \
    apt-get update && \
    apt-get -y install postgresql-client-16

# Golang 程序性能分析
ARG GO_VERSION
RUN curl -sSL -o go${GO_VERSION}.tar.gz https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz && \
    rm -rf /usr/local/go && tar -C /usr/local -xzf go${GO_VERSION}.tar.gz && \
    rm go${GO_VERSION}.tar.gz
ENV PATH=${PATH}:/usr/local/go/bin
RUN apt-get install -y graphviz
