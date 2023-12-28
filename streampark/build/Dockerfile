# 一定要顶头申明
ARG STREAMPARK_VERSION=dev

FROM registry.inventec/proxy/library/flink:1.12.7-scala_2.12 AS flink1.12.7-builder
FROM registry.inventec/proxy/library/flink:1.13.6-scala_2.12 AS flink1.13.6-builder
FROM registry.inventec/proxy/library/flink:1.14.6-scala_2.12 AS flink1.14.6-builder
FROM registry.inventec/proxy/library/flink:1.15.4-scala_2.12 AS flink1.15.4-builder
FROM registry.inventec/proxy/library/flink:1.16.3-scala_2.12 AS flink1.16.3-builder
FROM registry.inventec/proxy/library/flink:1.17.2-scala_2.12 AS flink1.17.2-builder

FROM registry.inventec/proxy/apache/streampark:$STREAMPARK_VERSION

COPY --from=flink1.12.7-builder /opt/flink /opt/flink/flink1.12/
COPY --from=flink1.13.6-builder /opt/flink /opt/flink/flink1.13/
COPY --from=flink1.14.6-builder /opt/flink /opt/flink/flink1.14/
COPY --from=flink1.15.4-builder /opt/flink /opt/flink/flink1.15/
COPY --from=flink1.16.3-builder /opt/flink /opt/flink/flink1.16/
COPY --from=flink1.17.2-builder /opt/flink /opt/flink/flink1.17/
