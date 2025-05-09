#!/bin/bash

# 获取 ssacli 输出
output=$(ssacli ctrl slot=3 ld all show detail)

echo "收集 S.M.A.R.T 信息..."
echo "------------------------------------------------------------"

# 提取并循环 Logical Drive 和对应的 /dev/sdX 设备名
echo "$output" | awk '
BEGIN {
    drive=""; disk="";
}
/^ *Logical Drive:/ {
    drive = $3
}
/^ *Disk Name:/ {
    disk = $3
    printf("%s %s\n", drive, disk);
}' | while read -r ld device; do
    echo ">>> Logical Drive: $ld, Device: $device"
    smartctl -d cciss,"$ld" -a "$device" | grep -A 3 'ID# ATTRIBUTE_NAME.*RAW_VALUE'
    echo "------------------------------------------------------------"
done
