#!/bin/bash

# 判断是否做了备份检查配置

pgbackrest --stanza=$PG_RESTORE_STANZA --log-level-console=info info
if [ $? -ne 0 ]
then
    echo "$(date "+%Y-%m-%d %H:%M:%S") Error: please check backup"
    exit 1
else
    RESTORE_TYPE=$(echo $PG_RESTORE_TYPE | tr [a-z] [A-Z])
    
    if [ "$RESTORE_TYPE" == "TIME" ]
    then
        if [[ $PG_RESTORE_TARGET_TIME=~^[0-9]{4}-[0-9]{2}-[0-9]{2}\s[0-9]{2}:[0-9]{2}:[0-9]{2}$ ]] && date -d "$PG_RESTORE_TARGET_TIME" >/dev/null 2>&1
        then
            echo "$(date "+%Y-%m-%d %H:%M:%S") INFO: start restore from ${STANZA} with point-in-time-recovery ${PG_RESTORE_TARGET_TIME} "
            pgbackrest --stanza=$PG_RESTORE_STANZA --delta --type=time "--target=${PG_RESTORE_TARGET_TIME}" --target-action=promote --log-level-console=info restore
            echo "$(date "+%Y-%m-%d %H:%M:%S") INFO: end restore"
        else
            echo "$(date "+%Y-%m-%d %H:%M:%S") ERROR: ${PG_RESTORE_TARGET_TIME} format is error please input the correct format 'YYYY-mm-dd HH:MM:SS'"
            exit 1
        fi
    elif [ "$RESTORE_TYPE" == "DATABASE" ]
    then
        echo "$(date "+%Y-%m-%d %H:%M:%S") INFO: start restore from ${PG_RESTORE_STANZA} with ${PG_RESTORE_DATABASE}"
        if [[ $PG_RESTORE_DATABASE=~"," ]]
        then
            oldIFS=$IFS;
            IFS=","
            begin="pgbackrest --stanza=${PG_RESTORE_STANZA} --delta --type=immediate --target-action=promote --log-level-console=info"
            middle="--db-include="
            element=""
            for item in $PG_RESTORE_DATABASE;
            do
                one=$middle$item
                element=$element" "$one
            done;
            command=$begin$element" ""restore"
            eval $command
        else
            pgbackrest --stanza=$PG_RESTORE_STANZA --delta --type=immediate --target-action=promote --db-include=$PG_RESTORE_DATABASE --log-level-console=info restore
        fi
        echo "$(date "+%Y-%m-%d %H:%M:%S") INFO: end restore"
    else
        echo "$(date "+%Y-%m-%d %H:%M:%S") INFO: start restore "
        pgbackrest --stanza=$PG_RESTORE_STANZA --delta --target-action=promote --log-level-console=info restore
        echo "$(date "+%Y-%m-%d %H:%M:%S") INFO: end restore"
    fi
fi
