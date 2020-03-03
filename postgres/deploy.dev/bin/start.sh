#!/bin/bash
set -e
cd `dirname $0`

docker stack deploy -c docker-compose-postgres.yml postgres
