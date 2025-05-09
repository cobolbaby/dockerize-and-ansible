#!/bin/bash

# 获取所有控制器的 Slot 编号
slots=$(ssacli ctrl all show | awk '/Slot [0-9]+/ { for (i=1; i<=NF; i++) if ($i == "Slot") print $(i+1) }')

# 遍历每个 Slot
for slot in $slots; do
    echo ">> 分析 Controller Slot: $slot"
    output=$(ssacli ctrl slot=$slot ld all show detail)

    echo "$output" | awk -v slot="$slot" '
    /^ *Logical Drive:/ {
        drive = $3
    }
    /^ *Disk Name:/ {
        disk = $3
        printf("%s %s %s\n", slot, drive, disk);
    }' | while read -r slot drive device; do
        echo ">>> Slot: $slot, Logical Drive: $drive, Device: $device"
        smartctl -d cciss,"$drive" -a "$device" | grep -A 2 'ID# ATTRIBUTE_NAME.*RAW_VALUE'
        echo "------------------------------------------------------------"
    done
done
