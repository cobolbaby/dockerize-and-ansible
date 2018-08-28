#! /bin/bash
REGISTRY=harbor.inventec.com

if [ -n "$1" ]; then
    BRANCH=$1
else
    BRANCH=latest
fi

TAGNAME=development/gpdb:${BRANCH}
PROXY=http://10.190.40.39:18118/