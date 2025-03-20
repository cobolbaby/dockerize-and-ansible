FROM registry.inventec/proxy/python:3.11-slim
LABEL maintainer="Zhang.Xing-Long@inventec.com"

USER root

RUN pip install --no-cache-dir --upgrade pip -i https://nexus.itc.inventec.net/repository/pypi-proxy/simple/

WORKDIR /usr/src/app

COPY src/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt -i https://nexus.itc.inventec.net/repository/pypi-proxy/simple/

COPY src/main.py .

COPY entrypoint.sh .
RUN chmod +x entrypoint.sh

ENV KAFKA_CONNECT_SERVICE_URL= \
    KAFKA_CONNECT_BOOTSTRAP_SERVERS= \
    REDPANDA_API=

ENTRYPOINT [ "./entrypoint.sh" ]
