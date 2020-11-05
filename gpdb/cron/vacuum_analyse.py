import os
import psycopg2
from datetime import datetime

dbname = os.environ.get('PG_DATABASE', '')
user = os.environ.get('PG_USER', '')
host = os.environ.get('PG_HOST', '')
password = os.environ.get('PG_PASS', '')
schema = os.environ.get('PG_SCHEMA', '')

class Vaccum(object):

    def __init__(self):
        """
        Connect to Postgre database.
        """
        c = "dbname='%s' user='%s' host='%s' password='%s' appname='vacuum-admin'"
        try:
            self.conn = psycopg2.connect(c % (dbname, user, host, password))
        except:
            raise Exception('Unable to connect to PostgreSQL.')

    def get_tables(self):
        """
        Get all tables in database's schema.
        """

        query = """
            SELECT table_name
            FROM information_schema.tables
            WHERE table_schema = '%s'
            """ % schema

    '''
    select concat (schemaname,'.',tablename)
    from pg_tables
    where schemaname not in ('information_schema', 'pg_catalog')
    order by 1

    测试膨胀的SQL

    SELECT relname, last_analyze, last_vacuum, last_autoanalyze, last_autovacuum FROM pg_stat_all_tables
WHERE schemaname = 'public'
ORDER BY relname;

select *, round(bdirelpages / bdiexppages,2) as rate, bdinspname || '.' || bdirelname as tb_name 
from gp_toolkit.gp_bloat_diag
where bdiexppages > 0 -- and bdinspname <> 'pg_catalog'
order by bdirelpages desc 
limit 100



    '''
        cur = self.conn.cursor()
        cur.execute(query)

        for table in cur.fetchall():
            yield(table[0])

    def vaccum(self, table):
        """
        Run Vacuum on a given table.
        """

        query = "VACUUM VERBOSE ANALYZE %s" % table

        # VACUUM can not run in a transaction block,
        # which psycopg2 uses by default.
        # http://bit.ly/1OUbYB3
        isolation_level = self.conn.isolation_level
        self.conn.set_isolation_level(0)

        cur = self.conn.cursor()
        cur.execute(query)

        # Set our isolation_level back to normal
        self.conn.set_isolation_level(isolation_level)

        return self.conn.notices


if __name__ == '__main__':

    v = Vaccum()
    for table in v.get_tables():

        # simple verbose printout for VACUUM process.
        now = datetime.utcnow()
        verbose = '[%s] VACUUM VERBOSE ANALYZE %s' % (now, table)
        print '=' * len(verbose)
        print verbose

        # 依据反馈的表信息来执行vacuum或者vacuum full

        # print out the VACUUM  VERBOSE results
        # using formating.
        notices = v.vaccum(table)
        for notice in notices:
            print notice

'''
Python 里面多行注释，多行文本怎么定义

multiprocessing.Process
'''

# Python 模拟登陆，发起请求。

