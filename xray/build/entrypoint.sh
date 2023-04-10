#!/bin/bash
set -e

# Domain(s) that this server should serve
CERTBOT_DOMAIN="${CERTBOT_DOMAIN:-cobolbaby.xyz}"

# Email address to use when registering for Certbot
CERTBOT_EMAIL="${CERTBOT_EMAIL:-cobolbaby@qq.com}"

CERTBOT_SSL_CERT_PATH="/etc/letsencrypt/live/$CERTBOT_DOMAIN/fullchain.pem"
CERTBOT_SSL_KEY_PATH="/etc/letsencrypt/live/$CERTBOT_DOMAIN/privkey.pem"

# Path to the Nginx SSL configuration file
NGINX_SSL_CONF="/etc/nginx/conf.d/${CERTBOT_DOMAIN}.conf"

XRAY_CONF="/opt/xray/config.json"

# Start nginx in the background
nginx 

sleep 5

# Obtain the SSL certificate
if [[ ! -f $CERTBOT_SSL_CERT_PATH || ! -f $CERTBOT_SSL_KEY_PATH ]]; then
    certbot certonly --non-interactive --agree-tos --email $CERTBOT_EMAIL --webroot --webroot-pat /usr/share/nginx/html -d $CERTBOT_DOMAIN
fi

# Update the Nginx SSL configuration file with the paths to the SSL certificate and key
cp /etc/nginx/conf.d/example.org.conf.tmpl $NGINX_SSL_CONF

sed -i "s|example.org|$CERTBOT_DOMAIN|g" $NGINX_SSL_CONF
sed -i "s|ssl_certificate .*|ssl_certificate $CERTBOT_SSL_CERT_PATH;|" $NGINX_SSL_CONF
sed -i "s|ssl_certificate_key .*|ssl_certificate_key $CERTBOT_SSL_KEY_PATH;|" $NGINX_SSL_CONF

# Check Nginx Configuration
nginx -t 

nginx -s reload

sed -i "s|\"id\": \"\"|\"id\": \"$(xray uuid)\"|" $XRAY_CONF
sed -i "s|\"certificateFile\": \".*\"|\"certificateFile\": \"$CERTBOT_SSL_CERT_PATH\"|" $XRAY_CONF
sed -i "s|\"keyFile\": \".*\"|\"keyFile\": \"$CERTBOT_SSL_KEY_PATH\"|" $XRAY_CONF

xray -config $XRAY_CONF
