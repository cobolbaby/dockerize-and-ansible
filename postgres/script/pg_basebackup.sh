#!/bin/bash
set -e
# set -o pipefail
cd `dirname $0`

pgrole=$(curl -s http://localhost:8008/patroni | jq .role | sed "s/\"//g")
if [ $pgrole = "master" ]; then
    echo "The role of ${PATRONI_NAME} database is master"
    exit
fi

# 针对物理备份，则相反，主节点停止，从节点继续，但如果是多个从的话，就需要从中找一个了，排序之后找第一个。
firstslave=$(curl -s http://localhost:8008/cluster | jq -c '.members[] | select(.role == "replica") | select(.lag == 0) | .name' | sort | head -n 1 | sed "s/\"//g")

# TODO:fix: 遇到过firstslave获取为空的情况，可能是Etcd异常了，而该异常会造成两个从节点都会进行数据备份
# ...

# PATRONI_NAME为当前节点名称
if [ $firstslave != $PATRONI_NAME ]; then
    echo "The current role of ${PATRONI_NAME} database is ${pgrole}, and the first slave node is ${firstslave}"
    exit
fi

echo "【`date`】Start to do pg_basebackup..."
# exit
BACKUP_DIR=/pgbackup/$(date +%Y%m%d%H%M%S)/basebackup
mkdir -p ${BACKUP_DIR} && cd ${BACKUP_DIR}

# -P 是否显示进度
# -Ft -z是否压缩
# time pg_basebackup -U postgres -D ${BACKUP_DIR} -Ft -z -Xs -Pv
# time pg_basebackup -U postgres -D - -Ft -Xs -v | pigz -6 -p 32 > ${BACKUP_DIR}/physical_backup.tgz
# pg_basebackup: cannot stream write-ahead logs in tar mode to stdout
time pg_basebackup -U postgres -D - -Ft -X fetch -v -c fast | pigz -6 -p 32 > ${BACKUP_DIR}/physical_backup.tgz

# 删除一个月之前的物理备份文件
cd /pgbackup
du -sh *
ls -t | tail -n +5 | xargs rm -rf
du -sh *

exit 0

# mc cp --recursive ${BACKUP_DIR} backup/infra-backup/postgresql/
