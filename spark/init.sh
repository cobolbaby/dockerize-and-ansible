#! /bin/bash

if [ -n "$1" ]; then
    BRANCH=$1
else
    BRANCH=latest
fi

TAGNAME=development/spark:${BRANCH}
PROXY=http://10.190.40.39:18118/

# INVENTORY_FILE=../inventory.dev
# REGISTRY=harbor.inventec.com

INVENTORY_FILE=../inventory.prod
REGISTRY=harbor.remote.inventec.com