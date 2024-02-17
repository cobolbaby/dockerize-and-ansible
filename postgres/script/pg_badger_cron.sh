#!/bin/bash
# set -e
cd `dirname $0`

current_date=$(date +"%Y-%m-%d")
echo $current_date

for i in $(docker ps | grep 'infra/postgres' | awk '{print $1}'); do 
    # fix: docker exec -ti $i /pgcron/pg_badger.sh $current_date 执行报 the input device is not a TTY
    docker exec $i /pgcron/pg_badger.sh $current_date
done

# previous_date=$(date -d "yesterday" +"%Y-%m-%d")
# echo $previous_date

# for i in $(docker ps -f "name=pg" --format "{{.Names}}"); do echo $i; docker exec -ti $i /pgcron/pg_badger.sh $previous_date; done
