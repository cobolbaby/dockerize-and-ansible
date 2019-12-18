#!/bin/bash
# set -e

# 启动SSH
/usr/sbin/sshd

while true; do echo Keep container alive...; sleep 1000; done
