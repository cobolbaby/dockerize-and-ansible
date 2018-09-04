#!/bin/bash
set -e

CONTAINERID="d17ff275d28a"

docker cp ./tasks ${CONTAINERID}:/opt/

# docker exec -ti ${CONTAINERID} spark-submit --master spark://sparkmaster:7077 /opt/tasks/pi.py
docker exec -ti ${CONTAINERID} spark-submit /opt/tasks/pi.py