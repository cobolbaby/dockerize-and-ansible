# Ref: https://docs.confluent.io/5.1.0/installation/versions-interoperability.html
FROM confluentinc/cp-kafka-connect:5.3.1
LABEL maintainer="Zhang.Xing-Long@inventec.com"

WORKDIR /usr/share/kafka/plugins

# https://github.com/Landoop/stream-reactor/releases/download/1.2.0/kafka-connect-cassandra-1.2.0-2.0.0-all.tar.gz
# ADD plugins/kafka-connect-cassandra-1.2.0-2.0.0-all.tar.gz .
# https://www.confluent.io/hub/debezium/debezium-connector-sqlserver
# ADD plugins/debezium-debezium-connector-sqlserver-1.0.0.zip .
# https://www.confluent.io/hub/debezium/debezium-connector-postgresql
# ADD plugins/debezium-debezium-connector-postgresql-1.0.0.zip .
ADD plugins /tmp

RUN apt-get update \
    && apt-get install -y net-tools unzip \
    && apt-get clean \
    && tar -zxvf /tmp/kafka-connect-cassandra-1.2.0-2.0.0-all.tar.gz -C . \
    && unzip /tmp/debezium-debezium-connector-sqlserver-1.0.0.zip \
    && unzip /tmp/debezium-debezium-connector-postgresql-1.0.0.zip \
    && mv /tmp/itc-connect-transforms-1.2.jar /usr/share/java/kafka/ \
    && rm -rf /tmp/*
