FROM registry.inventec/proxy/alpine:3.18

WORKDIR /app

COPY bin/proxy-webhook /app/proxy-webhook

ENTRYPOINT ["/app/proxy-webhook"]
