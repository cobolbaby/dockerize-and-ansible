# -*- coding: UTF-8 -*-
from __future__ import print_function

import os
from datetime import datetime

import psycopg2
from psycopg2 import extensions


class Vaccum(object):

    commands = {
        'gpdb': {
            'default': {
                'vacuum_full': ['VACUUM FULL', 'REINDEX TABLE', 'ANALYZE'],
                'vacuum': ['VACUUM ANALYZE'],
            },
            'pg_catalog': {
                'vacuum_full': ['REINDEX TABLE', 'VACUUM FULL ANALYZE'],
                'vacuum': ['REINDEX TABLE', 'VACUUM ANALYZE'],
            }
        },
        'postgre': {
            'default': {
                'vacuum_full': ['VACUUM FULL ANALYZE'],
                'vacuum': []
            },
        },
    }

    def __init__(self, dsn):
        """
        Connect to Postgre database.
        """
        try:
            self.conn = psycopg2.connect(dsn)
            self.server_type = self.get_server_type()
        except:
            raise

    def get_server_type(self):
        cur = self.conn.cursor()
        cur.execute('select version();')
        version = cur.fetchone()[0]
        return 'gpdb' if 'Greenplum Database' in version else 'postgre'

    def get_gpdb_bloat_tables(self):
        """
        Get all tables in database's schema.
        """

        query = """
            select
                schemaname,
                relname,
                n_dead_pages,
                n_live_pages,
                dead_tup_ratio,
                CASE WHEN dead_tup_ratio >= 25 THEN 'VACUUM_FULL' WHEN dead_tup_ratio >= 10 THEN 'VACUUM' ELSE '' END as strategy
            from
                (
                    select
                        pgn.nspname as schemaname,
                        pgc.relname as relname,
                        btdrelpages - btdexppages as n_dead_pages,
                        btdexppages as n_live_pages,
                        round(
                            (btdrelpages - btdexppages) * 100 / btdrelpages,
                            2
                        ) as dead_tup_ratio
                    from
                        gp_toolkit.gp_bloat_expected_pages beg
                        join pg_class pgc on beg.btdrelid = pgc.oid
                        join pg_namespace pgn on pgc.relnamespace = pgn.oid
                    where
                        btdrelpages > btdexppages
                        and (
                            (
                                btdrelpages - btdexppages > 10000
                                and pgn.nspname <> 'pg_catalog'
                                and pgn.nspname <> 'bsi_old'
                                and pgc.relname !~ 'pinresult'
                            )
                            or 
                            (
                                pgn.nspname = 'pg_catalog'
                                and pgc.relname <> 'gp_persistent_relation_node' 
                                -- and btdrelpages - btdexppages > 100
                            )
                        )
                    order by
                        dead_tup_ratio desc
                ) bloat
            limit
                30
        """

        cur = self.conn.cursor()
        cur.execute(query)

        for table in cur.fetchall():
            yield(table)

    def get_postgre_bloat_tables(self):
        """
        Get all tables in database's schema.
        """

        query = """
            select
                schemaname,
                relname,
                n_dead_tup,
                n_live_tup,
                dead_tup_ratio,
                CASE WHEN dead_tup_ratio >= 30 THEN 'VACUUM_FULL' ELSE '' END as strategy
            from
                (
                    select
                        schemaname,
                        relname,
                        n_dead_tup,
                        n_live_tup,
                        round(n_dead_tup * 100 / (n_live_tup + n_dead_tup), 2) as dead_tup_ratio
                    from
                        pg_stat_all_tables
                    where
                        n_dead_tup >= 10000
                        and round(n_dead_tup * 100 / (n_live_tup + n_dead_tup), 2) > 0
                    order by
                        dead_tup_ratio desc
                ) bloat
            limit
                10
        """

        cur = self.conn.cursor()
        cur.execute(query)

        for table in cur.fetchall():
            yield(table)

    def get_bloat_tables(self):
        strategy = 'get_' + self.server_type + '_bloat_tables'
        return getattr(self, strategy)()

    def execute(self, schema, table, cmds=[]):
        try:
            # VACUUM can not run in a transaction block,
            # which psycopg2 uses by default.
            # http://bit.ly/1OUbYB3
            isolation_level = self.conn.isolation_level
            self.conn.set_isolation_level(
                extensions.ISOLATION_LEVEL_AUTOCOMMIT)

            cur = self.conn.cursor()
            for cmd in cmds:
                verbose = "{0} {1} -- [{2}]".format(
                    cmd, '.'.join([schema, table]), datetime.now())
                print(verbose)
                cur.execute(verbose)

        finally:
            # Set our isolation_level back to normal
            self.conn.set_isolation_level(isolation_level)


def main(dsns=[], maintain_window={}):

    maintain_start_time = maintain_window.get(
        'start_time') if maintain_window.get('start_time') is not None else '00:00'
    maintain_end_time = maintain_window.get(
        'end_time') if maintain_window.get('end_time') is not None else '23:59'

    for dsn in dsns:
        print('*' * 100)
        print(dsn)
        print('*' * 100)

        # 如果启动时间不在维护时间范围内，则直接跳过
        if datetime.now().strftime("%H:%M") < maintain_start_time or datetime.now().strftime("%H:%M") > maintain_end_time:
            print(
                'Start time is not within the maintenance time range, waiting for the next scheduling.')
            continue

        try:
            counter = 0
            v = Vaccum(dsn)

            for table in v.get_bloat_tables():

                tbl_schema = table[0]
                tbl_table = table[1]
                tbl_dead_tup_ratio = table[4]
                tbl_operation = table[5]

                if tbl_operation == '':
                    continue

                # 如果超过了一次维护窗口期，则需要跳出循环，等待下一次调度
                if datetime.now().strftime("%H:%M") < maintain_start_time or datetime.now().strftime("%H:%M") > maintain_end_time:
                    print(
                        'The vacuum operation has exceeded the maintenance window, waiting for the next schedule.')
                    continue

                counter += 1

                verbose = "[%d][%s] %s %s.%s (dead_tup_ratio:%s)" % (
                    counter, datetime.now(), tbl_operation, tbl_schema, tbl_table, tbl_dead_tup_ratio)
                print('=' * 100)
                print(verbose)

                cmds = v.commands.get(v.server_type)
                if tbl_schema in cmds.keys():
                    v.execute(tbl_schema, tbl_table, cmds.get(
                        tbl_schema).get(tbl_operation.lower()))
                else:
                    v.execute(tbl_schema, tbl_table, cmds.get(
                        'default').get(tbl_operation.lower()))

            print('=' * 100)
            for notice in v.conn.notices:
                print(notice)

        except Exception as error:
            print("Oops! An exception has occured:", error)
            print("Exception TYPE:", type(error))


if __name__ == '__main__':

    dsns = [
       'postgresql://xxxx:xxxx@xxx:xxx/xxx?application_name=smart_vacuum',
    ]

    maintain_window = {
        'start_time': '01:00',
        'end_time': '02:30'
    }

    main(dsns, maintain_window)
