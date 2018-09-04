#!/bin/bash
set -e

echo "Getting container ID of the Spark master..."
CONTAINERID=`docker ps --filter name=sparkm --format "{{.ID}}"`

echo "Copying count.py script to the Spark master..."
docker cp ./tasks ${CONTAINERID}:/opt/

echo "Running Spark job..."
docker exec -ti ${CONTAINERID} spark-submit /opt/tasks/python/pi.py
# docker exec -ti ${CONTAINERID} spark-submit --master spark://sparkmaster:7077 /opt/tasks/pi.py