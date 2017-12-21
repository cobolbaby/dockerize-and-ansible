FROM nginx:stable
COPY ./config/nginx.conf /etc/nginx/
COPY ./html/502.html /usr/share/nginx/html/
EXPOSE 80 443
CMD ["nginx", "-g", "daemon off;"]