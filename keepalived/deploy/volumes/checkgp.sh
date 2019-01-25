#!/bin/sh

psqlCheck(){
    psql -h $1 -p 5432 -U gpadmin -d postgres -c 'select now();'
    if [ $? -ne 0 ]; then
        # psql: FATAL:  the database system is starting up
        # psql: FATAL:  DTM initialization: failure during startup recovery, retry failed, check segment status (cdbtm.c:1605)
        echo "$1 node gone away"
        return 1
    fi
    return 0
}

psqlCheck ${HOST_IP} || exit 1