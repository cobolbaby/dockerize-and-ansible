# -*- coding: UTF-8 -*-
# Code Design: http://assets.processon.com/chart_image/6232083f07912907c28a1eb7.png
from __future__ import print_function

import logging
import sys

import psycopg2

logger = logging.getLogger(__name__)
logger.setLevel(logging.DEBUG)

# 控制台日志
console_handler = logging.StreamHandler(sys.stdout)
# 为logger添加的日志处理器，可以自定义日志处理器让其输出到其他地方
logger.addHandler(console_handler)

def delete_table(conn, tbl):
    # https://stackoverflow.com/questions/5170546/how-do-i-delete-a-fixed-number-of-rows-with-sorting-in-postgresql
    q = """
        DELETE FROM {relname}
        WHERE ctid IN (
            SELECT ctid
            FROM {relname}
            WHERE {condition}
            LIMIT 100000
        );
    """.format(relname=tbl.get("relname"), condition=tbl.get("condition"))

    counter_size = 0
    counter_num = 0

    with conn.cursor() as cur:
        # TODO:如果删除 Table 的操作超时了，则直接跳过
        cur.execute('set statement_timeout = 60000;')

        while True:
            cur.execute(q)
            # conn.commit()

            counter_num += 1
            counter_size += cur.rowcount
            logger.info(f'Loop delete {counter_num} times from table {tbl.get("relname")}, clean {counter_size} rows.')
            
            if cur.rowcount < 100000:
                break

    return True
 
def drop_partition(conn, tbl):

    # 获取符合条件的历史分区？？？
    '''
    WITH q_expired_part AS (
        select
            *,
            ((regexp_match(part_expr, \$$ TO \('(.*)'\)\$$))[1])::timestamp without time zone as part_end
        from
            (
                select
                    format('%I.%I', n.nspname, p.relname) as parent_name,
                    format('%I.%I', n.nspname, c.relname) as part_name,
                    pg_catalog.pg_get_expr(c.relpartbound, c.oid) as part_expr
                from
                    pg_class p
                    join pg_inherits i ON i.inhparent = p.oid
                    join pg_class c on c.oid = i.inhrelid
                    join pg_namespace n on n.oid = c.relnamespace
                where
                    p.relname = '${relname}'
                    and n.nspname = '${nspname}'
                    and p.relkind = 'p'
            ) x
    )
    SELECT
        -- format('DROP TABLE IF EXISTS %s', part_name) as sql_to_exec
        part_name
    FROM
        q_expired_part
    WHERE
        part_end < CURRENT_DATE - '6 month'::interval
        and part_name !~* '(his|default|extra)$';
    '''

    return True

def vacuum_table(conn, tbl):

    q = "VACUUM ANALYSE {};".format(tbl.get("relname"))

    with conn.cursor() as cur:
        cur.execute('set statement_timeout = 1800000;')
        cur.execute(q)
        # conn.commit()

    return True

def reindex_table(conn, tbl):

    q = "REINDEX TABLE {};".format(tbl.get("relname"))

    with conn.cursor() as cur:
        cur.execute('set statement_timeout = 600000;')
        cur.execute(q)
        # conn.commit()

    return True

if __name__ == '__main__':

    db_archive = [
        {
            'dsn': 'postgresql://<username>:<password>@<host>:<port>/<dbname>?application_name=cleaner',
            'tables': [
                {
                    'relname': "public.cdc",
                    'condition': "cdt < date_trunc('day', now() - interval '15 days')",
                    'relispartition': False,
                    'pretest': [], # 预留检查入口
                }
            ]
        }
    ]

    # TODO:读取 json 配置，然后循环。。。

    for db in db_archive:
        try:
            logger.info('*' * 100)
            logger.info(db.get('dsn'))
            logger.info('*' * 100)

            conn = psycopg2.connect(dsn=db.get('dsn'))

            # fix: VACUUM cannot run inside a transaction block
            # which psycopg2 uses by default.
            # http://bit.ly/1OUbYB3
            conn.set_isolation_level(
                psycopg2.extensions.ISOLATION_LEVEL_AUTOCOMMIT)

            for tbl in db.get('tables'):
                # 优化时间分区表数据清理过程
                if tbl.get('relispartition'):
                    drop_partition(conn, tbl)
                else:
                    try:
                        delete_table(conn, tbl)
                    except (Exception, psycopg2.Error) as error:
                        logger.warn(error)
                    # TODO:借助 pg_repack 进行索引重建，否则会锁表
                    # pg_repack 提供 Pl/SQL 方式吗？
                    vacuum_table(conn, tbl)
                    reindex_table(conn, tbl)

            conn.close()

        except (Exception, psycopg2.Error) as error:
            logger.error(error)
        