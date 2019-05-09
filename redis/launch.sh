#!/bin/bash
. ./init.sh

sh clean.sh
date_str=`date "+%Y%m%d%H%M"`
docker run -d --name redis_${date_str} --net=host -h redis -p 6379:6379 -v /data/redis:/data ${REGISTRY}/${TAGNAME}
docker logs -f redis_${date_str}