# Ref: https://docs.confluent.io/5.1.0/installation/versions-interoperability.html
FROM confluentinc/cp-kafka-connect:5.0.3
LABEL maintainer="Zhang.Xing-Long@inventec.com"

# 直接打包至默认目录，启动的时候会报错，所以只能另外建一个目录
# ADD plugins/kafka-connect-cassandra-1.2.0-2.0.0-all.tar.gz /usr/share/java/kafka
RUN mkdir -p /usr/share/kafka/plugins
# ADD plugins/kafka-connect-cassandra-1.2.0-2.0.0-all.jar /usr/share/kafka/plugins

# Ref: https://github.com/Landoop/stream-reactor/releases
RUN curl -o kafka-connect-cassandra-1.2.0-2.0.0-all.tar.gz -sSL "https://github.com/Landoop/stream-reactor/releases/download/1.2.0/kafka-connect-cassandra-1.2.0-2.0.0-all.tar.gz" \
    && tar -zxvf kafka-connect-cassandra-1.2.0-2.0.0-all.tar.gz -C /usr/share/kafka/plugins