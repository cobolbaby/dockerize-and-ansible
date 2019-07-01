#!/bin/bash
set -e
cd `dirname $0`

curl -X POST localhost:9090/-/reload