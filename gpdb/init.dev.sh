#! /bin/bash
REGISTRY=harbor.inventec.com

if [ -n "$1" ]; then
    BRANCH=$1
else
    # BRANCH=4.3.30.4
    # BRANCH=5.15.1
    # BRANCH=5.17.0
    BRANCH=5.18.0
fi
TAGNAME=development/gpdb:${BRANCH}

PROXY=http://10.190.40.39:18118/