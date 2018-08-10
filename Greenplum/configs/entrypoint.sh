#!/bin/bash
cat /data/hosts/myhosts >> /etc/hosts
/usr/sbin/sshd -D
bin/bash