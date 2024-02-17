#!/bin/bash

# 判断是否做了备份检查配置

pgbackrest info --stanza=${PG_RESTORE_STANZA} --log-level-console=info
if [ $? -ne 0 ]
then
    echo "$(date "+%Y-%m-%d %H:%M:%S") Error: please check backup"
    exit 1
else
    echo "$(date "+%Y-%m-%d %H:%M:%S") INFO: reinit from ${PG_RESTORE_STANZA}, start restore"
    pgbackrest restore --delta --stanza=${PG_RESTORE_STANZA} --log-level-console=info
    echo "$(date "+%Y-%m-%d %H:%M:%S") INFO: end restore"
fi

# Bug:
# postgres@pg1201:~$ ~/reinit_script.sh 
# stanza: itc
#     status: error (missing stanza path)
# 2022-02-25 18:37:38 INFO: reinit from itc, start restore
# 2022-02-25 18:37:38.119 P00   INFO: restore command begin 2.37: --delta --exec-id=436136-aa804472 --log-level-console=info --log-level-file=info --pg1-path=/var/lib/postgresql/12/data --process-max=4 --repo1-host=pgbackrest --repo1-host-user=postgres --stanza=itc
# WARN: --delta or --force specified but unable to find 'PG_VERSION' or 'backup.manifest' in '/var/lib/postgresql/12/data' to confirm that this is a valid $PGDATA directory.  --delta and --force have been disabled and if any files exist in the destination directories the restore will be aborted.
# WARN: repo1: [FileMissingError] unable to load info file '/postgresql/12/backup/itc/backup.info' or '/postgresql/12/backup/itc/backup.info.copy':
#       FileMissingError: raised from remote-0 ssh protocol on 'pgbackrest': unable to open missing file '/postgresql/12/backup/itc/backup.info' for read
#       FileMissingError: raised from remote-0 ssh protocol on 'pgbackrest': unable to open missing file '/postgresql/12/backup/itc/backup.info.copy' for read
#       HINT: backup.info cannot be opened and is required to perform a backup.
#       HINT: has a stanza-create been performed?
# ERROR: [075]: no backup set found to restore
# 2022-02-25 18:37:38.387 P00   INFO: restore command end: aborted with exception [075]
# 2022-02-25 18:37:38 INFO: end restore
# postgres@pg1201:~$ echo $?
# 0
