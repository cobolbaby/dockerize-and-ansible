FROM nginx:stable
WORKDIR /etc/nginx
COPY ./config/nginx.conf .
COPY ./html/502.html /usr/share/nginx/html/
EXPOSE 80 443
CMD ["nginx", "-g", "daemon off;"]