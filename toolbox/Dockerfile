FROM registry.inventec/proxy/ubuntu:20.04

RUN apt-get update -y && \
    apt-get install -y --fix-missing \
            curl jq \
            net-tools tcpdump iperf3 iftop \
            sysstat iotop \
            strace gdb

ARG GO_VERSION
RUN curl -sSL -o go${GO_VERSION}.tar.gz https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz && \
    rm -rf /usr/local/go && tar -C /usr/local -xzf go${GO_VERSION}.tar.gz && \
    rm go${GO_VERSION}.tar.gz
ENV PATH $PATH:/usr/local/go/bin
RUN apt-get install -y graphviz
