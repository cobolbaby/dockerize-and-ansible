ARG GOLANG_VERSION=1.24.4
ARG TELEGRAF_VERSION=1.35.4

FROM registry.inventec/proxy/golang:${GOLANG_VERSION} AS builder

ENV GOPROXY=http://nexus.itc.inventec.net/repository/go-proxy/,https://goproxy.cn,https://goproxy.io,direct

WORKDIR /go/src

ARG TELEGRAF_VERSION

RUN git clone --depth 1 --branch v${TELEGRAF_VERSION} https://github.com/influxdata/telegraf.git && \
    cd telegraf && make build_tools

COPY config /opt/telegraf/config
COPY patch /opt/telegraf/patch

RUN cd telegraf && \
    git apply /opt/telegraf/patch/*.patch && \
    ./tools/custom_builder/custom_builder -config-dir /opt/telegraf/config

FROM registry.inventec/proxy/telegraf:${TELEGRAF_VERSION}-alpine

COPY --from=builder /go/src/telegraf/telegraf /usr/bin/telegraf
