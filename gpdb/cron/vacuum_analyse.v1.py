from __future__ import print_function

import os
from datetime import datetime

import psycopg2
from psycopg2 import extensions


class Vaccum(object):

    def __init__(self, dsn):
        """
        Connect to Postgre database.
        """
        try:
            self.conn = psycopg2.connect(dsn)
        except:
            raise Exception('Unable to connect to PostgreSQL.')

    def get_gpdb_bloat_tables(self):
        """
        Get all tables in database's schema.
        """

        query = """
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
                and pgc.relname <> 'gp_persistent_relation_node'
                and pgn.nspname <> 'bsi_old'
            order by dead_tup_ratio desc
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
        """

        cur = self.conn.cursor()
        cur.execute(query)

        for table in cur.fetchall():
            yield(table)

    def vacuum(self, table):
        """
        Run Vacuum on a given table.
        """
        vacuum_query = "VACUUM ANALYZE %s -- [%s]" % (
            table, datetime.utcnow())

        # VACUUM can not run in a transaction block,
        # which psycopg2 uses by default.
        # http://bit.ly/1OUbYB3
        isolation_level = self.conn.isolation_level
        self.conn.set_isolation_level(extensions.ISOLATION_LEVEL_AUTOCOMMIT)

        cur = self.conn.cursor()
        cur.execute(vacuum_query)

        # Set our isolation_level back to normal
        self.conn.set_isolation_level(isolation_level)

        return

    def vacuum_full(self, table):
        """
        Run Vacuum on a given table.
        """
        vacuum_query = "VACUUM FULL %s -- [%s]" % (
            table, datetime.utcnow())
        reindex_query = "REINDEX TABLE %s -- [%s]" % (
            table, datetime.utcnow())
        analyse_query = "ANALYZE %s -- [%s]" % (
            table, datetime.utcnow())

        # VACUUM can not run in a transaction block,
        # which psycopg2 uses by default.
        # http://bit.ly/1OUbYB3
        isolation_level = self.conn.isolation_level
        self.conn.set_isolation_level(extensions.ISOLATION_LEVEL_AUTOCOMMIT)

        cur = self.conn.cursor()
        cur.execute(vacuum_query)
        cur.execute(reindex_query)
        cur.execute(analyse_query)

        # Set our isolation_level back to normal
        self.conn.set_isolation_level(isolation_level)

        return

    def vacuum_catalog(self, table):
        """
        Run Vacuum on a given table.
        """
        vacuum_query = "VACUUM ANALYZE %s -- [%s]" % (
            table, datetime.utcnow())
        reindex_query = "REINDEX TABLE %s -- [%s]" % (
            table, datetime.utcnow())

        # VACUUM can not run in a transaction block,
        # which psycopg2 uses by default.
        # http://bit.ly/1OUbYB3
        isolation_level = self.conn.isolation_level
        self.conn.set_isolation_level(extensions.ISOLATION_LEVEL_AUTOCOMMIT)

        cur = self.conn.cursor()
        cur.execute(reindex_query)
        cur.execute(vacuum_query)

        # Set our isolation_level back to normal
        self.conn.set_isolation_level(isolation_level)

        return

    def vacuum_full_catalog(self, table):
        """
        Run Vacuum on a given table.
        """
        vacuum_query = "VACUUM FULL ANALYZE %s -- [%s]" % (
            table, datetime.utcnow())
        reindex_query = "REINDEX TABLE %s -- [%s]" % (
            table, datetime.utcnow())

        # VACUUM can not run in a transaction block,
        # which psycopg2 uses by default.
        # http://bit.ly/1OUbYB3
        isolation_level = self.conn.isolation_level
        self.conn.set_isolation_level(extensions.ISOLATION_LEVEL_AUTOCOMMIT)

        cur = self.conn.cursor()
        cur.execute(reindex_query)
        cur.execute(vacuum_query)

        # Set our isolation_level back to normal
        self.conn.set_isolation_level(isolation_level)

        return


def vacuum_analyse_for_gpdb(dsns):
    for dsn in dsns:
        print('*' * 100)
        print(dsn)
        print('*' * 100)

        counter = 0

        v = Vaccum(dsn)
        for table in v.get_gpdb_bloat_tables():
            counter += 1

            tbl_schema = table[0]
            tbl_table = table[1]
            tbl_bloat = table[4]

            if tbl_bloat < 10:
                continue

            print('=' * 100)
            if tbl_bloat > 50:
                verbose = "[%d][%s] VACUUM FULL ANALYZE %s.%s" % (
                    counter, datetime.utcnow(), tbl_schema, tbl_table)
                print(verbose)

                if tbl_schema == 'pg_catalog':
                    v.vacuum_full_catalog('.'.join([tbl_schema, tbl_table]))
                else:
                    v.vacuum_full('.'.join([tbl_schema, tbl_table]))
            else:
                verbose = "[%d][%s] VACUUM ANALYZE %s.%s" % (
                    counter, datetime.utcnow(), tbl_schema, tbl_table)
                print(verbose)

                if tbl_schema == 'pg_catalog':
                    v.vacuum_catalog('.'.join([tbl_schema, tbl_table]))
                else:
                    v.vacuum('.'.join([tbl_schema, tbl_table]))

        print('=' * 100)
        for notice in v.conn.notices:
            print(notice)


def vacuum_analyse_for_postgre(dsns):
    for dsn in dsns:
        print('*' * 100)
        print(dsn)
        print('*' * 100)

        counter = 0

        v = Vaccum(dsn)
        for table in v.get_postgre_bloat_tables():
            counter += 1

            tbl_schema = table[0]
            tbl_table = table[1]
            tbl_bloat = table[4]

            if tbl_bloat < 20:
                continue

            verbose = "[%d][%s] VACUUM FULL ANALYZE %s.%s" % (
                counter, datetime.utcnow(), tbl_schema, tbl_table)
            print('=' * 100)
            print(verbose)
            v.vacuum_full('.'.join([tbl_schema, tbl_table]))

        print('=' * 100)
        for notice in v.conn.notices:
            print(notice)


if __name__ == '__main__':
    vacuum_analyse_for_gpdb([
        'postgresql://xxxx:xxxx@xxxx:xxxx/xxxx?application_name=vacuum',
    ])
    vacuum_analyse_for_postgre([])
