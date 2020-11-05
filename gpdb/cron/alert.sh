#!/bin/bash


BUCKET_NAME=testbucket
OBJECT_NAME=testworkflow-2.0.1.jar
TARGET_LOCATION=/opt/test/testworkflow-2.0.1.jar
SQL='select * from "TB_ABC"'

JSON_FMT='{"bucketname":"%s","objectname":"%s","targetlocation":"%s","sql":"%s"}\n'
printf "$JSON_FMT" "$BUCKET_NAME" "$OBJECT_NAME" "$TARGET_LOCATION" "$SQL"

## set our environment variables for our database.
export PG_DATABASE=project
export PG_USER=user
export PG_PASS=password
export PG_SCHEMA=public
export PG_HOST=localhost

## execute the script to vacuum the database
$ python pg_vacuum.py