FROM redis:3.2-alpine
COPY ./config/redis.conf /usr/local/etc/redis/redis.conf
EXPOSE 6379
CMD [ "redis-server", "/usr/local/etc/redis/redis.conf" ]