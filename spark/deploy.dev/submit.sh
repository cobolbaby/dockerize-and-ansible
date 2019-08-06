#!/bin/bash
set -e

echo "【`date`】"

CURR_DIR=`dirname $0`

echo "Getting container ID of the Spark master..."
CONTAINERID=`docker ps --filter name=sparkm --format "{{.ID}}"`

echo "Running Spark job..."
docker exec ${CONTAINERID} /opt/spark/bin/spark-submit --master spark://sparkmaster:7077 --total-executor-cores 4 --verbose /opt/tasks/python/pi.py