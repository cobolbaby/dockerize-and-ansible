#!/bin/bash
set -e
cd `dirname $0`

# 热更新
curl -X POST localhost:9090/-/reload
curl -X POST localhost:9093/-/reload