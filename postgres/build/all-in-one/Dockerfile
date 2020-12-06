ARG PG_MAJOR=12

FROM postgres:$PG_MAJOR
LABEL maintainer="Zhang.Xing-Long@inventec.com"

ARG PG_MAJOR
ARG PGHOME=/home/postgres

# 安装Patroni
RUN pip3 install patroni[etcd]

# 分区表管理工具
RUN pip3 install pg_partman

# 表，索引在线重建工具
RUN pip3 install pg_repack

# 备份工具
RUN pip3 install pgbackrest

# 外部表扩展
# tds_fdw

# 附加工具pigz, net-tools, jq

