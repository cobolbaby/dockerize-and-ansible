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
            select distinct schemaname,tablename from pg_partitions 
            order by 1,2
        """

        cur = self.conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor)
        cur.execute(query)
        res = cur.fetchall()

        for r in res:
            if self.whitelist is None or len(self.whitelist) == 0:
                yield(r)
            else:
                if '.'.join([r['schemaname'], r['tablename']]) in self.whitelist:
                    yield(r)

    def get_partition_table_subpartitions(self, partition_table, sort='desc'):
        """
        Get all tables in database's schema.
        """

        query = """
            select schemaname,tablename,partitiontablename,partitionname,partitionrangestart,partitionrangeend,partitioneveryclause
            from pg_partitions 
            where schemaname = '{nspname}' and tablename = '{relname}' and partitionname <> 'extra'
            order by partitionrangestart {sort}
        """.format(nspname=partition_table['schemaname'], relname=partition_table['tablename'], sort=sort)

        cur = self.conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor)
        cur.execute(query)
        return cur.fetchall()

    def check_subpartition_isempty(self, subpartition):
        """
        Get all tables in database's schema.
        """

        query = """
            select * from {nspname}.{relname} limit 1;
        """.format(nspname=subpartition['schemaname'], relname=subpartition['partitiontablename'])

        cur = self.conn.cursor()
        cur.execute(query)

        print("Checking subpartition: ", subpartition,
              ", IsEmpty: ", cur.rowcount == 0)

        return cur.rowcount == 0

    def drop_subpartition(self, subpartition, rank=1):

        query = """
            ALTER TABLE {nspname}.{relname} DROP PARTITION FOR(RANK({rank}));
        """.format(nspname=subpartition['schemaname'], relname=subpartition['tablename'], rank=rank)

        print(query)

        cur = self.conn.cursor()
        cur.execute(query)

        return True

    def drop_subpartition_ack(self):
        return self.conn.commit()


def partition_cleaner(dsn, whitelist=None, maintain_window={"start_time": "00:00:00", "end_time": "23:59:59"}):
    
    if whitelist is None or len(whitelist) == 0:
        print("No whitelist provided, skipping.")
        return
    
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
        # 'ict.ictlogtestpart_ao_old',
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
