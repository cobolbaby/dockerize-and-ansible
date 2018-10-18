#!/bin/sh

if [ -z $1 ]; then
        echo 'No container specified...'
        echo 'Usage: '$0' gp|spark|cassandra'
        exit
fi

container=''
if [ "$1" = "gp" ];
        then container='gpdb:'
fi
if [ "$1" = "spark" ];
        then container='spark:'
fi
if [ "$1" = "cassandra" ];
        then container='cassandra:'
fi

if [ -z $container ]; then
        echo 'Unknown container specified...'
        echo 'Usage: '$0' gp|spark|cassandra'
        exit
fi

docker exec -it `docker ps|grep $container|sed 's/\s.*//'` bash