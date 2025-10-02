#!/bin/bash
set -e
cd `dirname $0`

export PGDATA_DEFAULT_TABLESPACE=/data/hdd/pg # itc pg
export PGDATA_DEFAULT_TABLESPACE=/data/hdd1/postgres # f3 pg dev
export PGDATA_DEFAULT_TABLESPACE=/data/ssd2/postgres # f6 pg dev
export PGDATA_DEFAULT_TABLESPACE=/data/ssd5/postgres-dev # tao pg dev
export PGDATA_DEFAULT_TABLESPACE=/data/ssd1/postgres # f6 ame pg dev

env | grep PGDATA

# 预先创建数据目录，可提前做 
# ansible -i ... postgres -m file -a "dest=${PGDATA_DEFAULT_TABLESPACE}/16/data owner=999 group=999 mode=700 state=directory"
# 如果是单点数据库，则可执行如下命令，结果一致
# sudo mkdir -p ${PGDATA_DEFAULT_TABLESPACE}/16/data
# sudo chown -R 999:999 ${PGDATA_DEFAULT_TABLESPACE}/16/data
# sudo chmod -R 700 ${PGDATA_DEFAULT_TABLESPACE}/16/data

# 数据库停服，停服前需确认哪台是 Leader 节点，要做到优雅退出
# 三步走: patronictl pause --wait, pg_ctl stop, docker stop 

# 如果是 Replica 节点，则修改 postgresql.conf 中的配置，如果是 Leader，则直接跳过 
# sudo sed -i 's/^primary/# &/' ${PGDATA_DEFAULT_TABLESPACE}/12/data/postgresql.conf
# sudo mv ${PGDATA_DEFAULT_TABLESPACE}/12/data/standby.signal ${PGDATA_DEFAULT_TABLESPACE}/12/data/standby.signal.del

docker run --rm \
	-e POSTGRES_INITDB_ARGS="--data-checksums" \
	-v ${PGDATA_DEFAULT_TABLESPACE}:/var/lib/postgresql \
	registry.inventec/infra/pg_upgrade:12-to-16.2 \
	--check
# or
docker run --rm \
	-v ${PGDATA_DEFAULT_TABLESPACE}:/var/lib/postgresql \
	registry.inventec/infra/pg_upgrade:12-to-16.2 \
	--check

# docker run --rm \
# 	-e POSTGRES_INITDB_ARGS="--data-checksums" \
# 	-v ${PGDATA_DEFAULT_TABLESPACE}:/var/lib/postgresql \
# 	registry.inventec/infra/pg_upgrade:12-to-16.2 \
# 	--link

# << comment

# Performing Consistency Checks
# -----------------------------
# Checking cluster versions                                     ok
# Checking database user is the install user                    ok
# Checking database connection settings                         ok
# Checking for prepared transactions                            ok
# Checking for system-defined composite types in user tables    ok
# Checking for reg* data types in user tables                   ok
# Checking for contrib/isn with bigint-passing mismatch         ok
# Checking for incompatible "aclitem" data type in user tables  ok
# Checking for user-defined encoding conversions                ok
# Checking for user-defined postfix operators                   ok
# Checking for incompatible polymorphic functions               ok
# Creating dump of global objects                               ok
# Creating dump of database schemas                             ok
# Checking for presence of required libraries                   ok
# Checking database user is the install user                    ok
# Checking for prepared transactions                            ok
# Checking for new cluster tablespace directories               ok

# If pg_upgrade fails after this point, you must re-initdb the
# new cluster before continuing.

# Performing Upgrade
# ------------------
# Setting locale and encoding for new cluster                   ok
# Analyzing all rows in the new cluster                         ok
# Freezing all rows in the new cluster                          ok
# Deleting files from new pg_xact                               ok
# Copying old pg_xact to new server                             ok
# Setting oldest XID for new cluster                            ok
# Setting next transaction ID and epoch for new cluster         ok
# Deleting files from new pg_multixact/offsets                  ok
# Copying old pg_multixact/offsets to new server                ok
# Deleting files from new pg_multixact/members                  ok
# Copying old pg_multixact/members to new server                ok
# Setting next multixact ID and offset for new cluster          ok
# Resetting WAL archives                                        ok
# Setting frozenxid and minmxid counters in new cluster         ok
# Restoring global objects in the new cluster                   ok
# Restoring database schemas in the new cluster                 ok
# Adding ".old" suffix to old global/pg_control                 ok

# If you want to start the old cluster, you will need to remove
# the ".old" suffix from /var/lib/postgresql/12/data/global/pg_control.old.
# Because "link" mode was used, the old cluster cannot be safely
# started once the new cluster has been started.
# Linking user relation files                                   ok
# Setting next OID for new cluster                              ok
# Sync data directory to disk                                   ok
# Creating script to delete old cluster                         ok
# Checking for extension updates                                notice

# Your installation contains extensions that should be updated
# with the ALTER EXTENSION command.  The file
#     update_extensions.sql
# when executed by psql by the database superuser will update
# these extensions.

# Upgrade Complete
# ----------------
# Optimizer statistics are not transferred by pg_upgrade.
# Once you start the new server, consider running:
#     /usr/lib/postgresql/16/bin/vacuumdb --all --analyze-in-stages
# Running this script will delete the old cluster's data files:
#     ./delete_old_cluster.sh

# comment

# 为了保证升级失败以后，原始数据能否有所保留，且原始数据不被篡改，不推荐采用硬连接的方式进行升级。
docker run --rm \
	-e POSTGRES_INITDB_ARGS="--data-checksums" \
	-v ${PGDATA_DEFAULT_TABLESPACE}:/var/lib/postgresql \
	registry.inventec/infra/pg_upgrade:12-to-16.2
# or
docker run --rm \
	-v ${PGDATA_DEFAULT_TABLESPACE}:/var/lib/postgresql \
	registry.inventec/infra/pg_upgrade:12-to-16.2

# << comment

# Performing Consistency Checks
# -----------------------------
# Checking cluster versions                                     ok
# Checking database user is the install user                    ok
# Checking database connection settings                         ok
# Checking for prepared transactions                            ok
# Checking for system-defined composite types in user tables    ok
# Checking for reg* data types in user tables                   ok
# Checking for contrib/isn with bigint-passing mismatch         ok
# Checking for incompatible "aclitem" data type in user tables  ok
# Checking for user-defined encoding conversions                ok
# Checking for user-defined postfix operators                   ok
# Checking for incompatible polymorphic functions               ok
# Creating dump of global objects                               ok
# Creating dump of database schemas                             ^[	^[	ok
# Checking for presence of required libraries                   ok
# Checking database user is the install user                    ok
# Checking for prepared transactions                            ok
# Checking for new cluster tablespace directories               ok

# If pg_upgrade fails after this point, you must re-initdb the
# new cluster before continuing.

# Performing Upgrade
# ------------------
# Setting locale and encoding for new cluster                   ok
# Analyzing all rows in the new cluster                         ok
# Freezing all rows in the new cluster                          ok
# Deleting files from new pg_xact                               ok
# Copying old pg_xact to new server                             ok
# Setting oldest XID for new cluster                            ok
# Setting next transaction ID and epoch for new cluster         ok
# Deleting files from new pg_multixact/offsets                  ok
# Copying old pg_multixact/offsets to new server                ok
# Deleting files from new pg_multixact/members                  ok
# Copying old pg_multixact/members to new server                ok
# Setting next multixact ID and offset for new cluster          ok
# Resetting WAL archives                                        ok
# Setting frozenxid and minmxid counters in new cluster         ok
# Restoring global objects in the new cluster                   ok
# Restoring database schemas in the new cluster                 ok
# Copying user relation files                                   ok
# Setting next OID for new cluster                              ok
# Sync data directory to disk                                   ok
# Creating script to delete old cluster                         ok
# Checking for extension updates                                notice

# Your installation contains extensions that should be updated
# with the ALTER EXTENSION command.  The file
#     update_extensions.sql
# when executed by psql by the database superuser will update
# these extensions.

# Upgrade Complete
# ----------------
# Optimizer statistics are not transferred by pg_upgrade.
# Once you start the new server, consider running:
#     /usr/lib/postgresql/16/bin/vacuumdb --all --analyze-in-stages
# Running this script will delete the old cluster's data files:
#     ./delete_old_cluster.sh

# comment

# 试跑启动，此时可以做一些配置修改，以及服务验证。
docker run -d --rm --name pg1602 \
	-e PGDATA=/var/lib/postgresql/16/data \
	-v ${PGDATA_DEFAULT_TABLESPACE}/16/data:/var/lib/postgresql/16/data \
    registry.inventec/infra/postgres:16.2

# TODO:如果是单点服务，需修改 $PGDATA/pg_hba.conf，添加 host all all all md5

# TODO:重建 PG HA 集群

# 刷新数据库的 collation，否则 psql 执行会有一堆提示
docker exec -ti pg1602 psql -c "ALTER DATABASE postgres REFRESH COLLATION VERSION;"

# 执行全库analyse
docker exec -ti pg1602 vacuumdb --all --analyze-in-stages
