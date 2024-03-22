ARG TAG

# Ref: https://docs.confluent.io/platform/current/installation/versions-interoperability.html
FROM registry.inventec/proxy/confluentinc/cp-kafka-connect:${TAG}
LABEL maintainer="Zhang.Xing-Long@inventec.com"

WORKDIR /usr/share/confluent-hub-components

ENV CONNECT_PLUGIN_PATH="/usr/share/java,/usr/share/confluent-hub-components"
RUN \
    # Remove the old connector plugin
    # https://docs.confluent.io/platform/current/connect/upgrade.html
    rm -rf /usr/share/java/kafka-connect-jdbc && \
    # https://www.confluent.io/hub/confluentinc/kafka-connect-jdbc
    confluent-hub install --no-prompt confluentinc/kafka-connect-jdbc:10.7.6 && \
    # https://www.confluent.io/hub/debezium/debezium-connector-sqlserver
    confluent-hub install --no-prompt debezium/debezium-connector-sqlserver:2.4.2 && \
    # https://www.confluent.io/hub/debezium/debezium-connector-postgresql
    confluent-hub install --no-prompt debezium/debezium-connector-postgresql:2.4.2 && \
    # https://www.confluent.io/hub/mongodb/kafka-connect-mongodb
    confluent-hub install --no-prompt mongodb/kafka-connect-mongodb:1.11.2 && \
    # https://www.confluent.io/hub/debezium/debezium-connector-mongodb
    confluent-hub install --no-prompt debezium/debezium-connector-mongodb:2.4.2 && \ 
    # https://www.confluent.io/hub/jcustenborder/kafka-connect-transform-common
    confluent-hub install --no-prompt jcustenborder/kafka-connect-transform-common:0.1.0.58

