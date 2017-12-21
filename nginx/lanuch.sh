#!/bin/bash
. ./init.sh

sh clean.sh
docker pull ${REGISTRY}/$TAGNAME
date_str=`date "+%Y%m%d%H%M"`
docker run -dti --name nginx_${date_str} --net=host -h nginx -p 80:80 -v /opt/shujuguan/www/feapp:/opt/shujuguan/www/feapp ${REGISTRY}/$TAGNAME
docker logs -f nginx_${date_str}