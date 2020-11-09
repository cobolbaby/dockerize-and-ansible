#!/usr/bin/env python
# -*- coding: utf-8 -*-

from __future__ import print_function

import json
import re
import sys

try:
    # 兼容Python2.7与3.x版本
    import httplib as client
except ImportError as e:
    from http import client

try:
    #　借助Greenplum打包的pygresql
    from pygresql import pg
except:
    try:
        import pg
    except ImportError as e:
        sys.exit(
            'Cannot import modules.  Please check that you have sourced greenplum_path.sh.  Detail: ' + str(e))


def send_mail(subject, content):
    '''
    Send email by insight
    '''

    payload = {
        'alarmTypeName': 'infra-monitor.gpcc',
        'mailFrom': 'BigDataQualityCenter@inventec.com',
        'mailTo': 'ITC180012',
        'mailSubject': subject,
        'mailContent': content,
    }
    headers = {
        'Content-type': 'application/json'
    }

    conn = client.HTTPConnection('10.190.80.236:8080')
    conn.request('POST', '/RestDMApplication/Rest/alarmPostData?userName=GPCC-Prod',
                 json.dumps(payload), headers)

    response = conn.getresponse()
    data = response.read()
    conn.close()

    return data.decode("utf-8")


MAIL_TEMPLATE = """
    <style>
        .styled-table {
            border-collapse: collapse;
            margin: 25px 0;
            font-size: 0.9em;
            font-family: sans-serif;
            min-width: 400px;
            box-shadow: 0 0 20px rgba(0, 0, 0, 0.15);
        }

        .styled-table thead tr {
            background-color: #009879;
            color: #ffffff;
            text-align: left;
        }
        
        .styled-table th,
        .styled-table td {
            padding: 12px 15px;
        }

        .styled-table tbody tr {
            border-bottom: 1px solid #dddddd;
        }

        .styled-table tbody tr:nth-of-type(even) {
            background-color: #f3f3f3;
        }
    </style>

    <table class="styled-table">
        <thead>
            <tr>
                <th>Name</th>
                <th>Value</th>
            </tr>
        </thead>
        <tbody>
            <tr>
                <td>RULEDESCRIPTION</td>
                <td>%s</td>
            </tr>
            <tr>
                <td>ALERTTIME</td>
                <td>%s %s</td>
            </tr>
            <tr>
                <td>SERVERNAME</td>
                <td>%s</td>
            </tr>
            <tr>
                <td>QUERYID</td>
                <td>%s</td>
            </tr>
            <tr>
                <td>QUERYTEXT</td>
                <td>%s</td>
            </tr>
            <tr>
                <td>REMARK</td>
                <td>%s</td>
            </tr>
            <!-- and so on... -->
        </tbody>
    </table>
"""


def connect_local_db(dsn):
    try:
        return pg.connect(dsn)
    except:
        raise


def alert_spilled_query(conn, sess_id):
    '''
    Spill files
    '''
    return alert_slow_query(conn, sess_id)


def alert_slow_query(conn, sess_id):
    '''
    Query runtime
    统计客户端IP，完整的SQL，最好能关联血缘，找出该任务的负责人
    '''
    sql = '''
        select
            procpid as pid,
            sess_id,
            datname,
            usename,
            client_addr,
            application_name,
            extract(epoch from(now() - query_start)) as query_stay
        from
            pg_stat_activity
        where
            sess_id = {}
    '''.format(sess_id)

    # Greenplum自身打包的pygresql版本较低，还不支持onedict，所以只能用dictresult
    res = conn.query(sql).dictresult()
    if res:
        return json.dumps(res[0])

    return ''


def alert_blocked_query(conn, sess_id):
    '''
    Query is blocked
    返回引起阻塞的SQL，依次为依据来优化任务调度计划
    '''
    sql = '''
        SELECT
            blocked_locks.pid AS blocked_pid,
            blocked_activity.datname AS datname,
            blocked_activity.usename AS blocked_user,
            blocked_activity.client_addr AS blocked_clientip,
            blocked_activity.application_name AS blocked_application,
            blocked_activity.current_query AS blocked_statement,
            blocking_locks.pid AS blocking_pid,
            blocking_activity.usename AS blocking_user,
            blocking_activity.client_addr AS blocking_clientip,
            blocking_activity.application_name AS blocking_application,
            blocking_activity.current_query AS current_statement
        FROM
            pg_catalog.pg_locks blocked_locks
            JOIN pg_catalog.pg_stat_activity blocked_activity 
                ON blocked_activity.procpid = blocked_locks.pid
            JOIN pg_catalog.pg_locks blocking_locks 
                ON blocking_locks.locktype = blocked_locks.locktype
                AND blocking_locks.database IS NOT DISTINCT FROM blocked_locks.database
                AND blocking_locks.relation IS NOT DISTINCT FROM blocked_locks.relation
                AND blocking_locks.page IS NOT DISTINCT FROM blocked_locks.page
                AND blocking_locks.tuple IS NOT DISTINCT FROM blocked_locks.tuple
                AND blocking_locks.virtualxid IS NOT DISTINCT FROM blocked_locks.virtualxid
                AND blocking_locks.transactionid IS NOT DISTINCT FROM blocked_locks.transactionid
                AND blocking_locks.classid IS NOT DISTINCT FROM blocked_locks.classid
                AND blocking_locks.objid IS NOT DISTINCT FROM blocked_locks.objid
                AND blocking_locks.objsubid IS NOT DISTINCT FROM blocked_locks.objsubid
                AND blocking_locks.pid != blocked_locks.pid
            JOIN pg_catalog.pg_stat_activity blocking_activity 
                ON blocking_activity.procpid = blocking_locks.pid
        WHERE
            NOT blocked_locks.granted
            AND blocked_activity.sess_id = {};
    '''.format(sess_id)
    res = conn.query(sql).dictresult()
    if res:
        return json.dumps(res)

    return ''


def alert_too_many_conn(conn):
    '''
    Connection
    统计最近5min内新建的数据库连接，看看客户端IP是什么，application_name是啥
    '''
    sql = '''
        SELECT
            client_addr,
            count(1) connections
        FROM
            pg_stat_activity
        WHERE
            now() - backend_start < interval '300 second'
            AND procpid <> pg_backend_pid()
        GROUP BY
            client_addr
        ORDER BY
            connections desc
    '''
    res = conn.query(sql).dictresult()
    return json.dumps(res)


if __name__ == "__main__":
    # Convert command line parameters into dict
    args = dict(l.split('=', 1) for l in sys.argv[1:])
    print(args)

    '''
    args = {
        "ACTIVERULENAME": "",
        "PGLOGS": "",
        "ALERTDATE": "2020-11-09",
        "SERVERNAME": "gpcc",
        "ALERTTIME": "13: 31: 23Z",
        "RULEDESCRIPTION": "Query runtime exceeds 8 min",
        "LOGID": "24068",
        "QUERYID": "1604464374-345372-1",
        "QUERYTEXT": "select dwfqas.func_insert_fact_fqas_pca_sn()",
        "LINK": "http: //172.19.0.6:28080",
        "SUBJECT": "Query runtime exceeds 8 min at 13:31:23Z on 2020-11-09"
    }
    '''

    subject = '[Greenplum]' + (args.get('SUBJECT') if args.get(
        'SUBJECT') is not None else 'Unknown Issue.')

    # 依据 RULEDESCRIPTION 来完善告警邮件的内容
    strategys = {
        'Spill files': alert_spilled_query,
        'Query runtime exceeds': alert_slow_query,
        'Query is blocked': alert_blocked_query,
        'Number of connections exceeds': alert_too_many_conn
    }

    remark = ''
    for characteristic in strategys.keys():
        if re.match(characteristic, args.get('RULEDESCRIPTION', ''), re.I) is None:
            continue

        try:
            conn = connect_local_db(
                'host=localhost port=5432 dbname=gpperfmon user=gpmon application_name=alert')

            # 从 QUERYID (xxx-xxx-xxx) 中拆解出 sessid，截取两个-号之间的信息
            query_id = args.get('QUERYID', '')
            if query_id != '':
                sess_id = query_id.split('-')[1]
                remark = strategys[characteristic](conn, sess_id)
            else:
                remark = strategys[characteristic](conn)

        except Exception as e:
            print("Oops! An exception has occured:", e)
            print("Exception TYPE:", type(e))
        finally:
            conn.close()

        # 匹配到一个规则，直接跳出循环
        break

    content = MAIL_TEMPLATE % (args.get('RULEDESCRIPTION'),
                               args.get('ALERTDATE'),
                               args.get('ALERTTIME'),
                               'IPT Greenplum Cluster',
                               args.get('QUERYID'),
                               args.get('QUERYTEXT'),
                               remark,
                               )

    res = send_mail(subject, content)
    print(res)
