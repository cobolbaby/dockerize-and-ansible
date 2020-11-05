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
                CASE WHEN dead_tup_ratio >= 25 THEN 'VACUUM_FULL' WHEN dead_tup_ratio >= 5 THEN 'VACUUM' ELSE '' END as strategy
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
                        and btdrelpages - btdexppages > 10000
                        and pgn.nspname <> 'bsi_old'
                        and pgc.relname <> 'pinresult'
                        and pgc.relname <> 'gp_persistent_relation_node'
                ) bloat
            order by
                dead_tup_ratio desc
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
                    limit
                        100
                ) bloat
            order by
                dead_tup_ratio desc
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
                    cmd, '.'.join([schema, table]), datetime.utcnow())
                print(verbose)
                cur.execute(verbose)

        finally:
            # Set our isolation_level back to normal
            self.conn.set_isolation_level(isolation_level)


def main(dsns=[]):
    for dsn in dsns:
        print('*' * 100)
        print(dsn)
        print('*' * 100)
        
        try:
            counter = 0
            v = Vaccum(dsn)

            for table in v.get_bloat_tables():

                tbl_schema = table[0]
                tbl_table = table[1]
                tbl_operation = table[5]

                if tbl_operation == '':
                    continue

                counter += 1

                verbose = "[%d][%s] %s %s.%s" % (
                    counter, datetime.utcnow(), tbl_operation, tbl_schema, tbl_table)
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

    main(dsns)
