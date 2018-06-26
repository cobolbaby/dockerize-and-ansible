#!/bin/bash

wget https://dl.eff.org/certbot-auto
chmod a+x ./certbot-auto
# 如何解决报错
./certbot-auto

certbot --nginx certonly
# 修改配置文件