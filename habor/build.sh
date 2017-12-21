#! /bin/bash
wget https://github.com/vmware/harbor/releases/download/v1.2.2/harbor-offline-installer-v1.2.2.tgz
tar -zxvf harbor-offline-installer-v1.2.2.tgz
cd harbor
# modify the hostname in the config file harbor.cfg

