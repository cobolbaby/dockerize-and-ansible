#!/bin/bash
set -e

echo "Getting container ID of the Spark master..."
CONTAINERID="eba80a9027bf"



docker cp ./tasks ${CONTAINERID}:/opt/

# docker exec -ti ${CONTAINERID} spark-submit --master spark://sparkmaster:7077 /opt/tasks/pi.py
docker exec -ti ${CONTAINERID} spark-submit /opt/tasks/pi.py