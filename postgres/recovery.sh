#!/bin/bash

# 根据物理备份做基于时间点的数据恢复
# ./pg_basebackup.sh

# 准备数据目录
sudo mkdir -p /data/postgres/16/data

# 将物理备份中的 tgz 包解压至数据目录
sudo tar -zxf /data/physical_backup.tgz -C /data/postgres/16/data

sudo chown -R 999:999 /data/postgres/16/data

# 修改 postgresql.conf 中的 recovery 参数
# recovery_target_time = '2024-11-24 00:00:30'

docker run --rm --name pg1604 \
    -p 5493:5432 \
    -e PGDATA=/var/lib/postgresql/16/data \
    -v /data/postgres/16/data:/var/lib/postgresql/16/data \
    registry.inventec/infra/postgres:16.4

# 结论: 无法做到基于时间点的恢复，最多恢复到备份时间点。
#  