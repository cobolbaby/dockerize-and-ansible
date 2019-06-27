# Ref: https://docs.confluent.io/5.1.0/installation/versions-interoperability.html
FROM confluentinc/cp-kafka-connect:5.1.3

# Ref: https://github.com/Landoop/stream-reactor/releases
RUN curl -o kafka-connect-cassandra-1.2.1-2.1.0-all.tar.gz -sSL "https://github.com/Landoop/stream-reactor/releases/download/1.2.1/kafka-connect-cassandra-1.2.1-2.1.0-all.tar.gz" \
    && tar -zxvf kafka-connect-cassandra-1.2.1-2.1.0-all.tar.gz -C /usr/share/java/kafka --strip-components=1