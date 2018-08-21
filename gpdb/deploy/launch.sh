#!/bin/bash
docker stack deploy -c docker-compose-segment.yml gpdb_segment
docker stack deploy -c docker-compose-master.yml gpdb_master