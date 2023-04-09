#!/bin/sh

# Start nginx in the background
nginx 

# Domain(s) that this server should serve
CERTBOT_DOMAIN="${CERTBOT_DOMAIN:-cobolbaby.xyz}"

# Email address to use when registering for Certbot
CERTBOT_EMAIL="${CERTBOT_EMAIL:-cobolbaby@qq.com}"

# Path to the Nginx SSL configuration file
NGINX_SSL_CONF="/etc/nginx/conf.d/${CERTBOT_DOMAIN}.conf"

# Obtain the SSL certificate
certbot certonly --non-interactive --agree-tos --email $CERTBOT_EMAIL --webroot --webroot-pat /usr/share/nginx/html -d $CERTBOT_DOMAIN

# Update the Nginx SSL configuration file with the paths to the SSL certificate and key
cp /etc/nginx/conf.d/server_ssl.conf.tmpl $NGINX_SSL_CONF

SSL_CERT_PATH="/etc/letsencrypt/live/$CERTBOT_DOMAIN/fullchain.pem"
SSL_KEY_PATH="/etc/letsencrypt/live/$CERTBOT_DOMAIN/privkey.pem"
sed -i "s|ssl_certificate .*|ssl_certificate $SSL_CERT_PATH;|" $NGINX_SSL_CONF
sed -i "s|ssl_certificate_key .*|ssl_certificate_key $SSL_KEY_PATH;|" $NGINX_SSL_CONF

sed -i "s|$\{DOMAIN\}|$CERTBOT_DOMAIN|g" $NGINX_SSL_CONF

# Check Nginx Configuration
nginx -t 

nginx -s reload

./xray -config ./config.json
