#!/bin/bash
set -e
cd `dirname $0`

# kong config init -c kong.conf

docker run -d --rm --name kong \
    -p 8000:8000 \
    -p 8443:8443 \
    -p 8001:8001 \
    -p 8444:8444 \
    -v "$(pwd)/kong.conf:/etc/kong/kong.conf" \
    -v "$(pwd)/kong.yml:/usr/local/kong/declarative/kong.yml" \
    -v "$(pwd)/nginx_kong.lua:/usr/local/share/lua/5.1/kong/templates/nginx_kong.lua" \
    -e "KONG_DECLARATIVE_CONFIG=/usr/local/kong/declarative/kong.yml" \
    -e "KONG_DATABASE=off" \
    -e "KONG_PROXY_ACCESS_LOG=/dev/stdout" \
    -e "KONG_ADMIN_ACCESS_LOG=/dev/stdout" \
    -e "KONG_PROXY_ERROR_LOG=/dev/stderr" \
    -e "KONG_ADMIN_ERROR_LOG=/dev/stderr" \
    -e "KONG_ADMIN_LISTEN=0.0.0.0:8001, 0.0.0.0:8444 ssl" \
    registry.inventec/hub/kong:1.5.1