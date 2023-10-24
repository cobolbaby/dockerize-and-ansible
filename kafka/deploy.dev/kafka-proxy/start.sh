#!/bin/bash

<< comment
docker run -d --rm --name kafka-native-proxy -p 30001-30003:30001-30003 registry.inventec/hub/grepplabs/kafka-proxy:v0.3.3 \
          server \
        --bootstrap-server-mapping "10.3.205.79:9092,0.0.0.0:30001,10.0.1.196:30001" \
        --bootstrap-server-mapping "10.3.205.89:9092,0.0.0.0:30002,10.0.1.196:30002" \
        --bootstrap-server-mapping "10.3.205.99:9092,0.0.0.0:30003,10.0.1.196:30003" \
        --dynamic-listeners-disable \
        --debug-enable \
        --log-level debug
comment

docker run --rm --name kafka-native-proxy -p 30001-30003:30001-30003 registry.inventec/hub/grepplabs/kafka-proxy:v0.3.3 \
          server \
        --bootstrap-server-mapping "10.3.205.79:9092,0.0.0.0:30001,10.190.5.106:30001" \
        --bootstrap-server-mapping "10.3.205.89:9092,0.0.0.0:30002,10.190.5.106:30002" \
        --bootstrap-server-mapping "10.3.205.99:9092,0.0.0.0:30003,10.190.5.106:30003" \
        --dynamic-listeners-disable \
        --debug-enable

