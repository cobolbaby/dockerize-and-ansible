#!/usr/bin/python3

import os
import sys
import psycopg2
import re
import subprocess

# 检测当前PG是否具备进行逻辑复制的参数配置


def parameter():
    conn = None
    conn = psycopg2.connect(database="postgres", user="",
                            password="", host="", port="")
    conn_sub = psycopg2.connect(database="postgres", user="",
                                password="", host="", port="")

    cur = conn.cursor()
    cur.execute("""show wal_level;""")
    rows = cur.fetchall()
    for row in rows:
        print("启用逻辑复制wal_level必须为logical")
        print("________________")
        print(row)
    cur = conn.cursor()
    cur.execute("""show max_worker_processes;""")
    rows = cur.fetchall()
    for row in rows:
        print("启用逻辑复制,请注意max_worker_process的数字")
        print("________________")
        print(row)
    cur = conn.cursor()
    cur.execute("""show max_replication_slots""")
    rows = cur.fetchall()
    for row in rows:
        print("启用逻辑复制,请注意复制槽的数字")
        print("________________")
        print(row)
    cur = conn.cursor()
    cur.execute("""show max_wal_senders;""")
    rows = cur.fetchall()
    for row in rows:
        print("启用逻辑复制,请注意最大max_wal_sender数字")
        print("________________")
        print(row)
    cur = conn.cursor()
    cur.execute("""show max_logical_replication_workers;""")
    rows = cur.fetchall()
    for row in rows:
        print("启用逻辑复制,请注意最大max_logical_replication_workers数字")
        print("________________")
        print(row)

    cur = conn.cursor()
    cur.execute("""show max_sync_workers_per_subscription;""")
    rows = cur.fetchall()
    for row in rows:
        print("启用逻辑复制,请注意最大max_sync_workers_per_subscription数字")
        print("________________")
        print(row)

    cur = conn.cursor()
    cur.execute(
        """select pubname,puballtables,pubinsert,pubupdate,pubdelete,pubtruncate from pg_publication;""")
    rows = cur.fetchmany(100)
    print("当前库publication定义发布信息")
    print("-----------------------------")
    print("发布定义名  是否对全库表进行发布定义  追踪插入  追踪更新  追踪删除        追踪truncate")
    for row in rows:
        print(row)

    print("----------------------------------------------")

    cur = conn.cursor()
    cur.execute("""select pubname,tablename from pg_publication_tables;""")
    rows = cur.fetchmany(100)
    print("当前库发布的数据表")
    print("------------------")
    print("发布定义名  发布表名")
    for row in rows:
        print(row)

    print("----------------------------------------------")

    cur = conn.cursor()
    cur.execute("""select relname,relhasindex
from pg_catalog.pg_class as c
inner join pg_namespace as n on
(c.relnamespace = n.oid and n.nspname NOT IN ('information_schema', 'pg_catalog') and c.relkind='r') where c.relhasindex = 'f';""")
    rows = cur.fetchmany(100)
    print("当前库不适合建立逻辑复制表list")
    print("_______________________________")
    print("表名  无主键")
    for row in rows:
        print(row)

    print("----------------------------------------------")

    cur = conn.cursor()
    cur.execute(
        """SELECT slot_name,slot_type,active FROM pg_replication_slots where active= 'f';""")
    rows = cur.fetchmany(100)
    print("注意当前没有被使用的复制槽，确认不使用请立即删除")
    print("_______________________________")
    print("复制槽名   复制槽类型   目前不在使用")
    for row in rows:
        print(row)
    print("删除复制槽语句 select pg_drop_replication('复制槽名')")
    print("------------------------------------------------------")

    cur = conn.cursor()
    cur.execute("""select sent_lsn,replay_lsn from pg_stat_replication;""")
    rows = cur.fetchmany(100)
    print("主库lsn信息")
    print("_______________________________")
    print("发送LSN     回执LSN")
    for row in rows:
        print(row)
    print("------------------------------------------------------")

    cur = conn_sub.cursor()
    cur.execute(
        """select subname,received_lsn,latest_end_time::varchar(20) from pg_stat_subscription;""")
    rows = cur.fetchmany(100)
    print("查看目的端数据接收状态")
    print("-----------------------")
    print("接收端名    接收到的LSN    最后接收到LSN时间")
    for row in rows:
        print(row)

    conn.commit()
    conn_sub.commit()
    conn_sub.close
    conn.close


if __name__ == "__main__":
    parameter()
