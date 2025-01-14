FROM registry.inventec/proxy/flink:1.18.1-scala_2.12-java17

ARG SEATUNNEL_VERSION

ENV SEATUNNEL_HOME="/opt/seatunnel"

RUN wget https://dlcdn.apache.org/seatunnel/${SEATUNNEL_VERSION}/apache-seatunnel-${SEATUNNEL_VERSION}-bin.tar.gz \
    && tar -xzvf apache-seatunnel-${SEATUNNEL_VERSION}-bin.tar.gz \
    && mv apache-seatunnel-${SEATUNNEL_VERSION} ${SEATUNNEL_HOME} \
    && rm -rf apache-seatunnel-${SEATUNNEL_VERSION}-bin.tar.gz

WORKDIR ${SEATUNNEL_HOME}

COPY config config

COPY maven /root/.m2/

ENV M2_HOME="/root/.m2"

RUN sh bin/install-plugin.sh ${SEATUNNEL_VERSION}

COPY plugins plugins
