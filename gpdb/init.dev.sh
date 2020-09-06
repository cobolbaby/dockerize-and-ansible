#! /bin/bash
REGISTRY=registry.inventec

if [ -n "$1" ]; then
    BRANCH=$1
else
    # BRANCH=4.3.30.4
    # BRANCH=5.15.1
    # BRANCH=5.17.0
    # BRANCH=5.18.0
    # BRANCH=5.18.0-rpm
    # BRANCH=5.19.0
    # BRANCH=5.21.5
    # BRANCH=5.27.1
    # BRANCH=5.28.0
    BRANCH=5.28.1
fi
TAGNAME=development/gpdb:${BRANCH}

PROXY=http://10.190.40.39:2379/
