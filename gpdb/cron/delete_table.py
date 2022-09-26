# -*- coding: UTF-8 -*-
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
                delete_table(conn, tbl)
                vacuum_table(conn, tbl)

            conn.close()

        except (Exception, psycopg2.Error) as error:
            print("Oops! An exception has occured:", error)
            print("Exception TYPE:", type(error))
        