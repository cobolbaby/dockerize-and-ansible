#!/bin/bash
set -e

CURR_DIR=`dirname $0`

echo "Getting container ID of the Spark master..."
CONTAINERID=`docker ps --filter name=sparkm --format "{{.ID}}"`

echo "Running Spark job..."
docker exec -ti ${CONTAINERID} spark-submit --master spark://sparkmaster:7077 /opt/tasks/python/pi.py