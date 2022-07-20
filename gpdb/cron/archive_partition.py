# -*- coding: UTF-8 -*-
from __future__ import print_function

import re
from ast import If
from datetime import datetime, timedelta

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
            select current_database() as datname,schemaname,tablename,partitiontablename,partitionname,partitionrangestart,partitionrangeend,partitioneveryclause
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

    def commit_tx(self):
        return self.conn.commit()

    def check_subpartition_canarchive(self, subpartition):
        """
        Get all tables in database's schema.
        """

        partitionrangeend = datetime.strptime(subpartition['partitionrangeend'].strip(
            "::timestamp without time zone").strip("'"), "%Y-%m-%d %H:%M:%S")

        print("Checking partitionrangeend of subpartition: ", partitionrangeend)

        if partitionrangeend < datetime.now() - timedelta(days=180):
            return True

        return False

    def migrate_subpartition_s3(self, subpartition, rank=1):
        """
        Get all tables in database's schema.
        """

        query = """
            CREATE WRITABLE EXTERNAL TABLE {nspname}.{relname}_ext (LIKE {nspname}.{partname})
            LOCATION('s3://infra-oss-fis-archive.ipt.inventec.net/greenplum/{datname}/{nspname}/{partname}/ config=/home/gpadmin/s3/s3.conf')
            FORMAT 'csv';

            INSERT INTO {nspname}.{relname}_ext SELECT * FROM {nspname}.{partname};

            DROP EXTERNAL TABLE {nspname}.{relname}_ext;

            CREATE EXTERNAL TABLE {nspname}.{partname}_ext (LIKE {nspname}.{partname})
            LOCATION('s3://infra-oss-fis-archive.ipt.inventec.net/greenplum/{datname}/{nspname}/{partname}/ config=/home/gpadmin/s3/s3.conf')
            FORMAT 'csv';

            ALTER EXTERNAL TABLE {nspname}.{partname}_ext
            OWNER to bdcenter;

            ALTER TABLE {nspname}.{relname} 
            EXCHANGE PARTITION FOR(RANK({rank}))
            WITH TABLE {nspname}.{partname}_ext WITHOUT VALIDATION;

            -- DROP TABLE {nspname}.{partname}_ext;
        """.format(datname=subpartition['datname'], nspname=subpartition['schemaname'], relname=subpartition['tablename'], partname=subpartition['partitiontablename'], rank=rank)

        print(query)

        # cur = self.conn.cursor()
        # cur.execute(query)

        return True

    def migrate_subpartition_tablespace(self, subpartition, rank=1):
        """
        Get all tables in database's schema.
        """

        query = """
            ALTER TABLE {nspname}.{partname}
            SET TABLESPACE tbs_hdd01;
        """.format(nspname=subpartition['schemaname'], partname=subpartition['partitiontablename'])

        print(query)

        # cur = self.conn.cursor()
        # cur.execute(query)

        return True


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
            # archiver.commit_tx()

    except (Exception, Error) as error:
        print("Oops! An exception has occured:", error)
        print("Exception TYPE:", type(error))


def partition_migrate(dsn, whitelist=None, maintain_window={"start_time": "00:00:00", "end_time": "23:59:59"}):

    if whitelist is None or len(whitelist) == 0:
        print("No whitelist provided, skipping.")
        return

    try:
        archiver = PartitionManager(dsn, whitelist)

        for partition_table in archiver.get_partition_tables():
            print("Archive partition table: ", partition_table)

            subpartitions = archiver.get_partition_table_subpartitions(
                partition_table, sort='asc')

            part_rank = 1

            for p in subpartitions:

                can_archive = archiver.check_subpartition_canarchive(p)
                if can_archive is False:
                    break

                # archiver.migrate_subpartition_s3(p, part_rank)
                archiver.migrate_subpartition_tablespace(p, part_rank)
                part_rank += 1

            # 最后一次性 commit
            # archiver.commit_tx()

    except (Exception, Error) as error:
        print("Oops! An exception has occured:", error)
        print("Exception TYPE:", type(error))


if __name__ == '__main__':

    dsns = [
        'postgresql://<username>:<password>@<host>:<port>/<dbname>?application_name=archiver',
    ]

    whitelist_clean = [
        # 'ict.ictlogtestpart_ao_old',
    ]
    whitelist_migrate = [
        # 'spi.testlogsolder'
    ]

    maintain_window = {
        'start_time': '01:00',
        'end_time': '02:30'
    }

    for dsn in dsns:
        print('*' * 100)
        print(dsn)
        print('*' * 100)

        # partition_cleaner(dsn, whitelist_clean, maintain_window)
        partition_migrate(dsn, whitelist_migrate, maintain_window)
