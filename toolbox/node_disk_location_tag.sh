#!/bin/bash

NODE=$(hostname)
TIME=$(date '+%F %T')

for MP in /data/*; do
    [ -d "$MP" ] || continue

    DISK=$(df -P "$MP" | awk 'NR==2 {print $1}')

    cat > "$MP/DISK_ORIGIN.info" <<EOF
node: $NODE
disk: $DISK
mount_point: $MP
created_at: $TIME
EOF

    echo "written: $MP/DISK_ORIGIN.info"
done
