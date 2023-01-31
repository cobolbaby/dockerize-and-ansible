# -*- coding: UTF-8 -*-
from __future__ import print_function

from datetime import datetime, timedelta

import psycopg2
from psycopg2 import extras


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

        cur = self.conn.cursor(cursor_factory=extras.RealDictCursor)
        cur.execute(query)
        res = cur.fetchall()

        for r in res:
            if self.whitelist is None or len(self.whitelist) == 0:
                yield(r)
            else:
                if r['schemaname'] + '.' + r['tablename'] in self.whitelist:
                    yield(r)

    def get_partition_table_subpartitions(self, partition_table, sort='desc'):
        """
        Get all tables in database's schema.
        """

        query = """
            select current_database() as datname,p.schemaname,p.tablename,p.partitiontablename,p.partitionname,p.partitionrangestart,p.partitionrangeend,p.partitioneveryclause,t.tablespace
            from pg_partitions p join pg_tables t on p.schemaname = t.schemaname and p.partitiontablename = t.tablename
            where p.schemaname = '{nspname}' and p.tablename = '{relname}' and p.partitionname <> 'extra'
            order by p.partitionrangestart {sort}
        """.format(nspname=partition_table['schemaname'], relname=partition_table['tablename'], sort=sort)

        cur = self.conn.cursor(cursor_factory=extras.RealDictCursor)
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

        partenttablename = subpartition['schemaname'] + \
            '.' + subpartition['tablename']
        threadhold = self.whitelist.get(partenttablename, 180)

        if partitionrangeend < datetime.now() - timedelta(days=threadhold):
            print(
                f"Partitionrangeend of subpartition: {partitionrangeend}(< -{threadhold}days)")
            return True

        return False

    def migrate_subpartition_s3(self, subpartition, rank=1):
        """
        Get all tables in database's schema.
        """

        # TODO:判断是否已经是 External Table 了
        # ...

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

        COLD_TABLESPACE = 'tbs_hdd01'

        if subpartition['tablespace'] == COLD_TABLESPACE:
            print(
                f"The subpartition {subpartition['partitiontablename']} is already in {COLD_TABLESPACE} tablespace.")
            return True

        query = """
            ALTER TABLE {nspname}.{partname}
            SET TABLESPACE {tablespace};
        """.format(nspname=subpartition['schemaname'], partname=subpartition['partitiontablename'], tablespace=COLD_TABLESPACE)

        print(query)

        cur = self.conn.cursor()
        cur.execute(query)

        return True

    def check_subpartition_needclean(self, subpartition):
        """
        判断最新分区是否创建的合理，暂定规则:
        如果可用分区数超过 20 个，或者提前一年创建出来，就先清理掉
        """

        partitionrangestart = datetime.strptime(subpartition['partitionrangestart'].strip(
            "::timestamp without time zone").strip("'"), "%Y-%m-%d %H:%M:%S")
        partitionrangeend = datetime.strptime(subpartition['partitionrangeend'].strip(
            "::timestamp without time zone").strip("'"), "%Y-%m-%d %H:%M:%S")
        partitionrangeinterval = partitionrangeend - partitionrangestart

        if partitionrangeend - datetime.now() > 20 * partitionrangeinterval \
                or partitionrangeend - datetime.now() > timedelta(days=365):
            print(f"Partitionrangeend of subpartition: {partitionrangeend}")
            return True

        return False

    def check_subpartition_needprecreate(self, subpartition):
        """
        确保可用分区数不超过 20 个，且最远不超过1年
        """

        partitionrangestart = datetime.strptime(subpartition['partitionrangestart'].strip(
            "::timestamp without time zone").strip("'"), "%Y-%m-%d %H:%M:%S")
        partitionrangeend = datetime.strptime(subpartition['partitionrangeend'].strip(
            "::timestamp without time zone").strip("'"), "%Y-%m-%d %H:%M:%S")
        partitionrangeinterval = partitionrangeend - partitionrangestart

        if partitionrangeend - datetime.now() < 20 * partitionrangeinterval \
                and partitionrangeend - datetime.now() < timedelta(days=365):
            print(f"Partitionrangeend of subpartition: {partitionrangeend}")
            return True

        return False

    def precreate_subpartition(self, subpartition):
        """
        ALTER TABLE spi.testlogsolder ADD PARTITION 
        START ('2022-12-31 00:00:00') INCLUSIVE 
        END ('2023-01-03 00:00:00') EXCLUSIVE;
        -- ERROR:  cannot add RANGE partition to relation "testlogsolder" with DEFAULT partition "extra"
        -- HINT:  need to SPLIT partition "extra"
        -- SQL state: 42P16

        ALTER TABLE spi.testlogsolder SPLIT DEFAULT PARTITION 
        START ('2022-12-31 00:00:00') INCLUSIVE 
        END ('2023-01-03 00:00:00') EXCLUSIVE 
        INTO (PARTITION solder_20221231, default partition);
        """

        partitionrangestart = datetime.strptime(subpartition['partitionrangestart'].strip(
            "::timestamp without time zone").strip("'"), "%Y-%m-%d %H:%M:%S")
        partitionrangeend = datetime.strptime(subpartition['partitionrangeend'].strip(
            "::timestamp without time zone").strip("'"), "%Y-%m-%d %H:%M:%S")
        partitionrangeinterval = partitionrangeend - partitionrangestart
        partitionname = subpartition['tablename'] + '_' + datetime.strftime(partitionrangeend, '%Y%m%d')

        query = """
            ALTER TABLE {nspname}.{relname} SPLIT DEFAULT PARTITION
            START ('{partitionrangestart}') INCLUSIVE 
            END ('{partitionrangeend}') EXCLUSIVE 
            INTO (PARTITION {partitionname}, default partition);
        """.format(nspname=subpartition['schemaname'], relname=subpartition['tablename'],
                   partitionrangestart=partitionrangeend,
                   partitionrangeend=partitionrangeend+partitionrangeinterval,
                   partitionname=partitionname)

        print(query)

        cur = self.conn.cursor()
        cur.execute(query)

        r = {
            'schemaname': subpartition['schemaname'],
            'tablename': subpartition['tablename'],
            'partitionrangestart': datetime.strftime(partitionrangeend, "%Y-%m-%d %H:%M:%S"),
            'partitionrangeend': datetime.strftime(partitionrangeend+partitionrangeinterval, "%Y-%m-%d %H:%M:%S"),
        }

        return r


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
                if archiver.check_subpartition_canarchive(p) is False:
                    break

                # archiver.migrate_subpartition_s3(p, part_rank)
                archiver.migrate_subpartition_tablespace(p, part_rank)
                part_rank += 1

                # 分批提交，避免形成长事务
                archiver.commit_tx()

    except (Exception, psycopg2.Error) as error:
        print("Oops! An exception has occured:", error)
        print("Exception TYPE:", type(error))


def partition_governance(dsn, whitelist=None, maintain_window={"start_time": "00:00:00", "end_time": "23:59:59"}):

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
                if archiver.check_subpartition_needclean(p) is False:
                    break

                if archiver.check_subpartition_isempty(p) is False:
                    break

                archiver.drop_subpartition(p, part_rank)
                part_rank -= 1

            latest_subpartition = subpartitions[0]
            while archiver.check_subpartition_needprecreate(latest_subpartition):
                latest_subpartition = archiver.precreate_subpartition(
                    latest_subpartition)

            subpartitions = archiver.get_partition_table_subpartitions(
                partition_table, sort='asc')

            for p in subpartitions:
                if archiver.check_subpartition_isempty(p) is False:
                    break

                archiver.drop_subpartition(p, 1)

            # 最后一次性 commit
            archiver.commit_tx()

    except (Exception, psycopg2.Error) as error:
        print("Oops! An exception has occured:", error)
        print("Exception TYPE:", type(error))


if __name__ == '__main__':

    dsns = [
        'postgresql://<username>:<password>@<host>:<port>/<dbname>?application_name=archiver',
    ]

    whitelist_clean = [
        'ict.ictlogtestpart_ao_old',
    ]
    whitelist_migrate = {
        'ict.ictlogtestpart_ao': 90,
    }

    maintain_window = {
        'start_time': '01:00',
        'end_time': '02:30'
    }

    for dsn in dsns:
        print('*' * 100)
        print(dsn)
        print('*' * 100)

        partition_migrate(dsn, whitelist_migrate, maintain_window)
        partition_governance(dsn, whitelist_migrate, maintain_window)
