#!/bin/bash

cp docker-compose.yml docker-compose_14_0_12.yml
sed -i "s/infra\/gitlab\/gitlab-ce:13.12.15-ce.0/proxy\/gitlab\/gitlab-ce:14.0.12-ce.0/" docker-compose_14_0_12.yml
# 删除 ITC AD 之外的其他域控
# 删除 unicorn['log_directory'] = "/var/log/gitlab/unicorn"
# 增加 puma['log_directory'] = "/var/log/gitlab/puma"
# 增加 shm_size: 1g

docker-compose -f docker-compose_14_0_12.yml up -d
# 等待 https://gitlab.icz.inventec.net/admin/background_migrations 执行完，时间比较长，接近一个小时

cp docker-compose_14_0_12.yml docker-compose_14_3_6.yml
sed -i "s/14.0.12-ce.0/14.3.6-ce.0/" docker-compose_14_3_6.yml
diff docker-compose_14_0_12.yml docker-compose_14_3_6.yml

docker-compose -f docker-compose_14_3_6.yml up -d
# 等待 https://gitlab.icz.inventec.net/admin/background_migrations 执行完，时间还算快，几分钟

cp docker-compose_14_3_6.yml docker-compose_14_9_5.yml
sed -i "s/14.3.6-ce.0/14.9.5-ce.0/" docker-compose_14_9_5.yml
diff docker-compose_14_3_6.yml docker-compose_14_9_5.yml

docker-compose -f docker-compose_14_9_5.yml up -d
# 等待 https://gitlab.icz.inventec.net/admin/background_migrations 执行完，时间不短，半个小时

cp docker-compose_14_9_5.yml docker-compose_14_10_5.yml
sed -i "s/14.9.5-ce.0/14.10.5-ce.0/" docker-compose_14_10_5.yml
diff docker-compose_14_9_5.yml docker-compose_14_10_5.yml

docker-compose -f docker-compose_14_10_5.yml up -d
# 等待 https://gitlab.icz.inventec.net/admin/background_migrations 执行完，时间也得等一会，20分钟

cp docker-compose_14_10_5.yml docker-compose_15_0_5.yml
sed -i "s/14.10.5-ce.0/15.0.5-ce.0/" docker-compose_15_0_5.yml
diff docker-compose_14_10_5.yml docker-compose_15_0_5.yml

docker-compose -f docker-compose_15_0_5.yml up -d
# 等待 https://gitlab.icz.inventec.net/admin/background_migrations 执行完，很快

mv docker-compose.yml docker-compose_13_12_15.yml
cp docker-compose_13_12_15.yml docker-compose_15_4_4.yml
sed -i "s/13.12.15-ce.0/15.4.4-ce.0/" docker-compose_15_4_4.yml
# 删除 unicorn['log_directory'] = "/var/log/gitlab/unicorn"
# 增加 puma['log_directory'] = "/var/log/gitlab/puma"
# 增加 shm_size: 1g
diff docker-compose_13_12_15.yml docker-compose_15_4_4.yml

docker-compose -f docker-compose_15_4_4.yml up -d
# 等待 https://gitlab.icz.inventec.net/admin/background_migrations 执行完，后台跑的任务很多，得有个1个多小时

cp docker-compose_15_4_6.yml docker-compose_15_11_13.yml
sed -i "s/15.4.6-ce.0/15.11.13-ce.0/" docker-compose_15_11_13.yml
diff docker-compose_15_4_6.yml docker-compose_15_11_13.yml

docker-compose -f docker-compose_15_11_13.yml up -d

cp docker-compose_15_11_13.yml docker-compose_16_3_9.yml
sed -i "s/infra\/gitlab\/gitlab-ce:15.11.13-ce.0/proxy\/gitlab\/gitlab-ce:16.3.9-ce.0/" docker-compose_16_3_9.yml
diff docker-compose_15_11_13.yml docker-compose_16_3_9.yml

docker-compose -f docker-compose_16_3_9.yml up -d

cp docker-compose_16_3_9.yml docker-compose_16_7_10.yml
sed -i "s/16.3.9-ce.0/16.7.10-ce.0/" docker-compose_16_7_10.yml
diff docker-compose_16_3_9.yml docker-compose_16_7_10.yml

docker-compose -f docker-compose_16_7_10.yml up -d

cp docker-compose_16_7_10.yml docker-compose_16_11_10.yml
sed -i "s/proxy\/gitlab\/gitlab-ce:16.7.10-ce.0/infra\/gitlab\/gitlab-ce:16.11.10-ce.0/" docker-compose_16_11_10.yml
diff docker-compose_16_7_10.yml docker-compose_16_11_10.yml

docker-compose -f docker-compose_16_11_10.yml up -d

cp docker-compose_16_11_10.yml docker-compose_17_1_8.yml
sed -i "s/infra\/gitlab\/gitlab-ce:16.11.10-ce.0/proxy\/gitlab\/gitlab-ce:17.1.8-ce.0/" docker-compose_17_1_8.yml
diff docker-compose_16_11_10.yml docker-compose_17_1_8.yml

docker-compose -f docker-compose_17_1_8.yml up -d

cp docker-compose_17_1_8.yml docker-compose_17_3_7.yml
sed -i "s/17.1.8-ce.0/17.3.7-ce.0/" docker-compose_17_3_7.yml
diff docker-compose_17_1_8.yml docker-compose_17_3_7.yml

docker-compose -f docker-compose_17_3_7.yml up -d

cp docker-compose_17_3_7.yml docker-compose_17_5_5.yml
sed -i "s/17.3.7-ce.0/17.5.5-ce.0/" docker-compose_17_5_5.yml
diff docker-compose_17_3_7.yml docker-compose_17_5_5.yml

docker-compose -f docker-compose_17_5_5.yml up -d

cp docker-compose_17_5_5.yml docker-compose_17_8_7.yml
sed -i "s/17.5.5-ce.0/17.8.7-ce.0/" docker-compose_17_8_7.yml
diff docker-compose_17_5_5.yml docker-compose_17_8_7.yml

docker-compose -f docker-compose_17_8_7.yml up -d

cp docker-compose_17_8_7.yml docker-compose_17_11_7.yml
sed -i "s/17.8.7-ce.0/17.11.7-ce.0/" docker-compose_17_11_7.yml
diff docker-compose_17_8_7.yml docker-compose_17_11_7.yml

docker-compose -f docker-compose_17_11_7.yml up -d

# 讨论是否要升级到 18.x 非 LTS 版本
# ...

cp docker-compose_17_11_7.yml docker-compose_18_2_8.yml
sed -i "s/17.11.7-ce.0/18.2.8-ce.0/" docker-compose_18_2_8.yml
diff docker-compose_17_11_7.yml docker-compose_18_2_8.yml

docker-compose -f docker-compose_18_2_8.yml up -d

cp docker-compose_18_2_8.yml docker-compose_18_5_5.yml
sed -i "s/18.2.8-ce.0/18.5.5-ce.0/" docker-compose_18_5_5.yml
diff docker-compose_18_2_8.yml docker-compose_18_5_5.yml

docker-compose -f docker-compose_18_5_5.yml up -d

cp docker-compose_18_5_5.yml docker-compose_18_8_3.yml
sed -i "s/proxy\/gitlab\/gitlab-ce:18.5.5-ce.0/infra\/gitlab\/gitlab-ce:18.8.3-ce.0/" docker-compose_18_8_3.yml
diff docker-compose_18_5_5.yml docker-compose_18_8_3.yml

docker-compose -f docker-compose_18_8_3.yml up -d
