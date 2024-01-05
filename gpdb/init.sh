#! /bin/bash
REGISTRY=registry.inventec

if [ -n "$1" ]; then
    BRANCH=$1
else
    # BRANCH=4.3.30.4
    # BRANCH=5.15.1
    # BRANCH=5.17.0
    # BRANCH=5.18.0
    # BRANCH=5.21.5
    # BRANCH=5.24.0
    # BRANCH=6.11.2
    # BRANCH=6.12.0
    # BRANCH=6.13.0
    # BRANCH=6.14.0
    # BRANCH=6.16.0
    # BRANCH=6.19.1
    # BRANCH=6.20.5
    # BRANCH=6.23.0
    # BRANCH=6.24.4
    BRANCH=6.25.3
fi
TAGNAME=infra/gpdb:${BRANCH}

PROXY=http://10.190.81.209:3389
