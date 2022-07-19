# -*- coding: UTF-8 -*-
from __future__ import print_function

import re
from ast import If

import psycopg2
from psycopg2 import Error, extras


class PartitionManager(object):

    def __init__(self, dsn=[], whitelist=None):
        """
        Connect to Postgre database.
        """
        try:
            self.conn = psycopg2.connect(dsn)
            self.whitelist = whitelist
        except:
            raise

    def get_partition_tables(self):
        """
        Get all tables in database's schema.
        """

        query = """
            select n.nspname,c.relname
            from (
                select distinct inhparent as inhparent from pg_inherits
            ) i 
            join pg_class c on c.oid = i.inhparent
            join pg_namespace n on c.relnamespace = n.oid
            where c.relkind = 'r'
        """

        cur = self.conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor)
        cur.execute(query)
        res = cur.fetchall()

        for r in res:
            if self.whitelist is None or len(self.whitelist) == 0:
                yield(r)
            else:
                if '.'.join([r['nspname'], r['relname']]) in self.whitelist:
                    yield(r)

    def get_partition_table_subpartitions(self, partition_table, sort='desc'):
        """
        Get all tables in database's schema.
        """

        query = """
            select
                *
            from
                (
                    SELECT
                        i.inhparent::regclass::character varying AS parent_name,
                        i.inhrelid::regclass::character varying AS part_name,
                        pg_get_expr(pr1.parrangestart, pr1.parchildrelid) pstart,
                        pg_get_expr(pr1.parrangeend, pr1.parchildrelid) pend,
                        pg_get_expr(pr1.parrangeevery, pr1.parchildrelid) pduration
                    FROM pg_inherits AS i
                    JOIN pg_partition_rule AS pr1 ON i.inhrelid = pr1.parchildrelid
                    WHERE i.inhparent = '{nspname}.{relname}'::regclass
                ) x
            where part_name !~ '_extra$'
            order by
                pstart {sort}
        """.format(nspname=partition_table['nspname'], relname=partition_table['relname'], sort=sort)

        cur = self.conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor)
        cur.execute(query)
        return cur.fetchall()

    def check_subpartition_isempty(self, subpartition):
        """
        Get all tables in database's schema.
        """

        query = """
            select * from {subpartition_name} limit 1;
        """.format(subpartition_name=subpartition['part_name'])

        cur = self.conn.cursor()
        cur.execute(query)

        print("Checking subpartition: ", subpartition,
              ", IsEmpty: ", cur.rowcount == 0)

        return cur.rowcount == 0

    def drop_subpartition(self, subpartition, rank=1):

        query = """
            ALTER TABLE {partition_table} DROP PARTITION FOR(RANK({rank}));
        """.format(partition_table=subpartition['parent_name'], rank=rank)

        print(query)

        cur = self.conn.cursor()
        cur.execute(query)

        return True

    def drop_subpartition_ack(self):
        return self.conn.commit()


def partition_cleaner(dsn, whitelist=None, maintain_window={"start_time": "00:00:00", "end_time": "23:59:59"}):
    try:
        archiver = PartitionManager(dsn, whitelist)

        for partition_table in archiver.get_partition_tables():
            print("Archive partition table: ", partition_table)

            subpartitions = archiver.get_partition_table_subpartitions(
                partition_table, sort='desc')

            part_rank = len(subpartitions)

            for p in subpartitions:

                is_empty = archiver.check_subpartition_isempty(p)
                if is_empty is False:
                    break

                archiver.drop_subpartition(p, part_rank)
                part_rank -= 1

            subpartitions = archiver.get_partition_table_subpartitions(
                partition_table, sort='asc')

            for p in subpartitions:

                is_empty = archiver.check_subpartition_isempty(p)
                if is_empty is False:
                    break

                archiver.drop_subpartition(p, part_rank=1)

            # 最后一次性 commit
            # archiver.drop_subpartition_ack()

    except (Exception, Error) as error:
        print("Oops! An exception has occured:", error)
        print("Exception TYPE:", type(error))


if __name__ == '__main__':

    dsns = [
        'postgresql://<username>:<password>@<host>:<port>/<dbname>?application_name=archiver',
    ]

    whitelist = [
        'ict.ictlogtestpart_ao_old',
    ]

    maintain_window = {
        'start_time': '01:00',
        'end_time': '02:30'
    }

    for dsn in dsns:
        print('*' * 100)
        print(dsn)
        print('*' * 100)

        partition_cleaner(dsn, whitelist, maintain_window)
