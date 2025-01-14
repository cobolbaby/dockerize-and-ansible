#!/bin/bash

# 参数设置
INSTANCE="10.190.81.165"
USERNAME="sa"
PASSWORD="YourStrong!Passw0rd"
BACKUP_DIR="/tmp/mssql/backup"
BUCKET_NAME="infra-backup"
MINIO_ENDPOINT="https://infra-oss.itc.inventec.net"
MAX_JOBS=4

# 创建备份文件夹
mkdir -p $BACKUP_DIR

# 获取所有数据库列表
DATABASES=$(sqlcmd -S $INSTANCE -U $USERNAME -P $PASSWORD -Q "SELECT name FROM sys.databases WHERE name NOT IN ('master', 'tempdb', 'model', 'msdb')" -h -1)

# 备份和上传函数
backup_and_upload() {
    DATABASE_NAME=$1
    BACKUP_PATH="$BACKUP_DIR/$DATABASE_NAME.bak"
    
    # 备份数据库
    echo "开始备份数据库：$DATABASE_NAME"
    sqlcmd -S $INSTANCE -U $USERNAME -P $PASSWORD -Q "BACKUP DATABASE [$DATABASE_NAME] TO DISK = N'$BACKUP_PATH' WITH INIT, COMPRESSION;"
    
    # 上传到 MinIO
    echo "上传备份文件到 MinIO：$BACKUP_PATH"
    aws s3 cp $BACKUP_PATH s3://$BUCKET_NAME/$DATABASE_NAME.bak --endpoint-url $MINIO_ENDPOINT
    
    echo "数据库 $DATABASE_NAME 备份并上传完成。"
}

# 使用 parallel 并行执行备份
export -f backup_and_upload
export INSTANCE USERNAME PASSWORD BACKUP_DIR BUCKET_NAME MINIO_ENDPOINT
echo "$DATABASES" | parallel -j $MAX_JOBS backup_and_upload
