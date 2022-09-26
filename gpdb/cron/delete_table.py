# -*- coding: UTF-8 -*-
# Code Design: http://assets.processon.com/chart_image/6232083f07912907c28a1eb7.png
from __future__ import print_function

import logging

import psycopg2

logger = logging.getLogger("dev")
logger.setLevel(logging.DEBUG)

def delete_table(conn, tbl):
    
    with conn.cursor() as cur:
        while True:
            cur.execute("DELETE FROM %s WHERE %s LIMIT 10000;", (tbl.get("relname"), tbl.get("condition")))
            conn.commit()
            
            if cur.rowcount == 0:
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

    with conn.cursor() as cur:
        cur.execute("VACUUM ANALYSE %s;", (tbl.get("relname")))
        conn.commit()

    return True

if __name__ == '__main__':

    db_archive = [
        {
            'dsn': 'postgresql://<username>:<password>@<host>:<port>/<dbname>?application_name=archiver',
            'tables': [
                {
                    'relname': "dw.fact_pca_yield_unit",
                    'condition': "udt < '2021-10-01 00:00:00'",
                    'relispartition': False,
                    'pretest': [], # 预留检查入口
                }
            ]
        }
    ]

    for db in db_archive:
        try:
            print('*' * 100)
            print(db.get('dsn'))
            print('*' * 100)

            conn = psycopg2.connect(db.get('dsn'))
            conn.initialize(logger)

            for tbl in db.get('tables'):
                # 优化时间分区表数据清理过程
                if tbl.get('relispartition'):
                    drop_partition(conn, tbl)
                else:
                    delete_table(conn, tbl)
                    vacuum_table(conn, tbl)

            conn.close()

        except (Exception, psycopg2.Error) as error:
            print("Oops! An exception has occured:", error)
            print("Exception TYPE:", type(error))
        