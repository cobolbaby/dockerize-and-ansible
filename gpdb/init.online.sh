#! /bin/bash
REGISTRY=harbor.remote.inventec.com

if [ -n "$1" ]; then
    BRANCH=$1
else
    BRANCH=latest
fi

TAGNAME=development/gpdb:${BRANCH}