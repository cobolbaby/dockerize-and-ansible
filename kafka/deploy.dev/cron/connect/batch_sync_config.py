# -*-coding:utf-8-*-
import pymssql
import psycopg2
import psycopg2.extras
import psycopg2.pool
import configparser

config = None


def getConfig():
    global config
    if config is None:
        config = configparser.ConfigParser()
        config.read('config.txt')
    return config


def get_cdc_tableList():
    global f_ss, d_ss
    conn = pymssql.connect(host=getConfig().get(f_ss, 'ip'),
                           port=getConfig().get(f_ss, 'port'),
                           user=getConfig().get(f_ss, 'user'),
                           password=getConfig().get(f_ss, 'ps'),
                           database=d_ss
                           # ,charset='d_ss'
                           )
    cursor = conn.cursor()
    sql = "SELECT name FROM sys.tables WHERE is_tracked_by_cdc <> 0"
    # print(sql)
    cursor.execute(sql)
    rs = cursor.fetchall()
    conn.close()
    result = []
    for name in rs:
        result.append(name[0])
    return result


def get_mssql_metadata():
    # 查询mssql表元数据
    global f_ss, d_ss, t_ss
    conn = pymssql.connect(host=getConfig().get(f_ss, 'ip'),
                           port=getConfig().get(f_ss, 'port'),
                           user=getConfig().get(f_ss, 'user'),
                           password=getConfig().get(f_ss, 'ps'),
                           database=d_ss
                           # ,charset='utf8'
                           )
    cursor = conn.cursor(as_dict=True)
    sql = f'''SELECT
        col.colorder AS 序号 ,  
        col.name AS 列名 ,  
        convert(nvarchar(max),ISNULL(ep.[value], '')) AS 列说明 ,  
        t.name AS 数据类型 ,  
        CASE WHEN col.length = -1 THEN 8000 ELSE col.length END AS 长度 , 
        CASE WHEN EXISTS ( SELECT   1  
                           FROM     dbo.sysindexes si  
                                    INNER JOIN dbo.sysindexkeys sik ON si.id = sik.id  
                                                              AND si.indid = sik.indid  
                                    INNER JOIN dbo.syscolumns sc ON sc.id = sik.id  
                                                              AND sc.colid = sik.colid  
                                    INNER JOIN dbo.sysobjects so ON so.name = si.name  
                                                              AND so.xtype = 'PK'  
                           WHERE    sc.id = col.id  
                                    AND sc.colid = col.colid ) THEN 1  
             ELSE 0  
        END AS 主键 ,  
        CASE WHEN col.isnullable = 1 THEN 'null'  
             ELSE 'not null'  
        END AS 允许空,
        convert(nvarchar(max),ISNULL(epTwo.[value], '')) as 表说明
FROM    dbo.syscolumns col  
        LEFT  JOIN dbo.systypes t ON col.xtype = t.xusertype  
        inner JOIN dbo.sysobjects obj ON col.id = obj.id  
                                         AND obj.xtype = 'U'  
                                         AND obj.status >= 0  
        LEFT  JOIN dbo.syscomments comm ON col.cdefault = comm.id  
        LEFT  JOIN sys.extended_properties ep ON col.id = ep.major_id  
                                                      AND col.colid = ep.minor_id  
                                                      AND ep.name = 'MS_Description'  
        LEFT  JOIN sys.extended_properties epTwo ON obj.id = epTwo.major_id  
                                                         AND epTwo.minor_id = 0  
                                                         AND epTwo.name = 'MS_Description'  
WHERE   obj.name = '{t_ss}'
ORDER BY col.colorder;'''

    # print(sql)
    cursor.execute(sql)
    rs = cursor.fetchall()
    conn.close()
    return rs


def create_pg_table(mssql_metadata):
    # 根据mssql表元数据，创建pg表
    global f_pg, d_pg, t_pg
    field_sql = ''
    primary_key = ''
    for r in mssql_metadata:
        # 列名转换
        r["列名"] = '"' + r["列名"].replace(' ', '_').lower() + '"'
        # 判断主键栏位
        if r["主键"] == 1:
            if primary_key == '':
                primary_key = r["列名"]
            else:
                primary_key = primary_key + ', ' + r["列名"]
        # 处理数据类型映射
        flag = 0
        if r["数据类型"] == 'nvarchar' or r["数据类型"] == 'varchar' or r["数据类型"] == 'uniqueidentifier':
            r["数据类型"] = 'varchar'
            if field_sql == '':
                field_sql = f'{r["列名"]} {r["数据类型"]}({r["长度"]}) {r["允许空"]}'
            else:
                field_sql = field_sql + ',\n' + f'{r["列名"]} {r["数据类型"]}({r["长度"]}) {r["允许空"]}'
            flag = 1
        if r["数据类型"] == 'char':
            if field_sql == '':
                field_sql = f'{r["列名"]} {r["数据类型"]}({r["长度"]}) {r["允许空"]}'
            else:
                field_sql = field_sql + ',\n' + f'{r["列名"]} {r["数据类型"]}({r["长度"]}) {r["允许空"]}'
            flag = 1
        if r["数据类型"] == 'int' or r["数据类型"] == 'tinyint':
            r["数据类型"] = 'int'
            if field_sql == '':
                field_sql = f'{r["列名"]} {r["数据类型"]} {r["允许空"]}'
            else:
                field_sql = field_sql + ',\n' + f'{r["列名"]} {r["数据类型"]} {r["允许空"]}'
            flag = 1

        if r["数据类型"] == 'money':
            r["数据类型"] = 'float'
            if field_sql == '':
                field_sql = f'{r["列名"]} {r["数据类型"]} {r["允许空"]}'
            else:
                field_sql = field_sql + ',\n' + f'{r["列名"]} {r["数据类型"]} {r["允许空"]}'
            flag = 1
        if r["数据类型"] == 'text' or r["数据类型"] == 'bigint' or r["数据类型"] == 'real':
            if field_sql == '':
                field_sql = f'{r["列名"]} {r["数据类型"]} {r["允许空"]}'
            else:
                field_sql = field_sql + ',\n' + f'{r["列名"]} {r["数据类型"]} {r["允许空"]}'
            flag = 1
        if r["数据类型"] == 'datetime':
            r["数据类型"] = 'timestamp'
            if field_sql == '':
                field_sql = f'{r["列名"]} {r["数据类型"]} {r["允许空"]}'
            else:
                field_sql = field_sql + ',\n' + f'{r["列名"]} {r["数据类型"]} {r["允许空"]}'
            flag = 1
        if r["数据类型"] == 'bit':
            r["数据类型"] = 'boolean'
            if field_sql == '':
                field_sql = f'{r["列名"]} {r["数据类型"]} {r["允许空"]}'
            else:
                field_sql = field_sql + ',\n' + f'{r["列名"]} {r["数据类型"]} {r["允许空"]}'
            flag = 1
        if flag == 0:
            if field_sql == '':
                field_sql = f'{r["列名"]} {r["数据类型"]}({r["长度"]}) {r["允许空"]}'
            else:
                field_sql = field_sql + ',\n' + f'{r["列名"]} {r["数据类型"]}({r["长度"]}) {r["允许空"]}'
    # 生成pg建表sql(包含主键约束)
    if primary_key != '':
        sql = field_sql + ',\n' + f"CONSTRAINT {t_pg.split('.')[1]}_pkey PRIMARY KEY ({primary_key})"
    else:
        sql = field_sql

    if f_pg.endswith('BDC'):
        if primary_key != '':
            create_table_sql = f"""CREATE TABLE {t_pg}
(
{sql}
)
TABLESPACE pg_default
distributed by ({primary_key});"""
        else:
            create_table_sql = f"""CREATE TABLE {t_pg}
(
{sql}
)
TABLESPACE pg_default
distributed by (???);"""
    else:
        create_table_sql = f"""CREATE TABLE {t_pg}
(
{sql}
)
TABLESPACE pg_default;"""

    print(create_table_sql)

    simple_conn_pool = psycopg2.pool.SimpleConnectionPool(minconn=1, maxconn=10,
                                                          dbname=d_pg,
                                                          user=getConfig().get(f_pg, 'user'),
                                                          password=getConfig().get(f_pg, 'ps'),
                                                          host=getConfig().get(f_pg, 'ip'),
                                                          port=getConfig().get(f_pg, 'port'))
    conn = simple_conn_pool.getconn()
    with conn:
        cur = conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor)
        table_exists = f"select to_regclass('{t_pg}') is not null as exists"
        cur.execute(table_exists)
        exists_ss = cur.fetchone()
        if exists_ss['exists']:
            print(f'{t_pg} is existed in {f_pg}!')
        else:
            cur.execute(create_table_sql)
            conn.commit()
            print(f'{t_pg}表创建成功!')


def pg_comment(mssql_metadata):
    # 同步mssql表注释到pg表
    global f_pg, d_pg, t_pg

    simple_conn_pool = psycopg2.pool.SimpleConnectionPool(minconn=1, maxconn=10,
                                                          dbname=d_pg,
                                                          user=getConfig().get(f_pg, 'user'),
                                                          password=getConfig().get(f_pg, 'ps'),
                                                          host=getConfig().get(f_pg, 'ip'),
                                                          port=getConfig().get(f_pg, 'port'))
    conn = simple_conn_pool.getconn()
    with conn:
        cur = conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor)
        # 表注释
        # print(mssql_metadata[0]["表说明"])
        table_comment = mssql_metadata[0]["表说明"]
        if table_comment != '':
            table_comment_sql = f"COMMENT ON TABLE {t_pg} IS '{table_comment}';"
            cur.execute(table_comment_sql)
            print(f'{t_pg}表comment信息录入成功!')
            print(table_comment_sql)
        else:
            print(f'{t_pg}表无comment信息!')
            pass
        # 字段注释
        for r in mssql_metadata:
            # 列名转换
            column_name = r["列名"].replace(' ', '_').lower()
            field_comment = r["列说明"]
            if field_comment != '':
                comment_sql = f"COMMENT ON COLUMN {t_pg}.{column_name} IS '{field_comment}';"
                cur.execute(comment_sql)
                print(f'{t_pg}.{column_name}字段comment信息录入成功!')
                print(comment_sql)
            else:
                print(f'{t_pg}.{column_name}字段无comment信息!')
                pass
            conn.commit()


def print_sync_data(mssql_metadata):
    global f_ss, t_ss, d_ss, t_pg, flag, st, et
    print(f"'dbo', '{t_ss}',")
    print(f"'{t_pg.split('.')[0]}', '{t_pg.split('.')[1]}',")
    cols = ''
    primary_key = ''
    sys_keys = ['name', 'source', 'data', 'sysid', 'sequence', 'alias', 'type', 'attribute', 'line', 'value', 'source', 'location', 'version']
    for r in mssql_metadata:
        if r["主键"] == 1:
            if primary_key == '':
                primary_key = r["列名"].replace(' ', '_').lower()
            else:
                primary_key = primary_key + ',' + r["列名"].replace(' ', '_').lower()
        if cols == '':
            if r["列名"].lower() in sys_keys:
                cols = r["列名"] + ' as ' + r["列名"].lower()
            else:
                cols = r["列名"]
        else:
            if r["列名"].lower() in sys_keys:
                cols = cols + ',' + r["列名"] + ' as ' + r["列名"].lower()
            else:
                cols = cols + ',' + r["列名"]
    print(f"'{cols}',")
    print(f"'{primary_key}',")


    if flag == 'repair':
        # 补数据
         # and Udt between ''2023-03-14'' and ''2023-03-15''
        if 'Udt' in cols and primary_key != '':
            src_where_statement = f"${{SRC_INCR_FIELD}} > ''${{INCR_POINT}}'' and Udt between ''{st}'' and ''{et}''"
            fields_mapping = '{"Udt": "udt"}'
            sync_data_sql = f"insert into manager.job_data_sync (src_schema_name, src_table_name, dst_schema_name, " \
                            f"dst_table_name, src_select_statement, src_where_statement, sync_mode, src_incr_field," \
                            f" dst_pk, fields_mapping, incr_point, src_type, src_db_name) values " \
                            f"('dbo', '{t_ss}', '{t_pg.split('.')[0]}', '{t_pg.split('.')[1]}', '{cols}', '"+ src_where_statement +"', 'merge', '1'," \
                            f" '{primary_key}', '" + fields_mapping + f"', '-1', '{f_ss}', '{d_ss}')"
            print(sync_data_sql)
        elif 'Cdt' in cols and primary_key != '':
            src_where_statement = f"${{SRC_INCR_FIELD}} > ''${{INCR_POINT}}'' and Cdt between ''{st}'' and ''{et}''"
            fields_mapping = '{"Cdt": "cdt"}'
            sync_data_sql = f"insert into manager.job_data_sync (src_schema_name, src_table_name, dst_schema_name, " \
                            f"dst_table_name, src_select_statement, src_where_statement, sync_mode, src_incr_field," \
                            f" dst_pk, fields_mapping, incr_point, src_type, src_db_name) values " \
                            f"('dbo', '{t_ss}', '{t_pg.split('.')[0]}', '{t_pg.split('.')[1]}', '{cols}', '"+ src_where_statement +"', 'merge', '1'," \
                            f" '{primary_key}', '" + fields_mapping + f"', '-1', '{f_ss}', '{d_ss}')"
            print(sync_data_sql)
        else:
            src_where_statement = "${SRC_INCR_FIELD} > ''${INCR_POINT}''"
            sync_data_sql = f"insert into manager.job_data_sync (src_schema_name, src_table_name, dst_schema_name, " \
                            f"dst_table_name, src_select_statement, src_where_statement, sync_mode, src_incr_field," \
                            f" dst_pk, incr_point, src_type, src_db_name) values " \
                            f"('dbo', '{t_ss}', '{t_pg.split('.')[0]}', '{t_pg.split('.')[1]}', '{cols}', '"+ src_where_statement +"', 'full', '1'," \
                            f" '{primary_key}', '-1', '{f_ss}', '{d_ss}')"
            print('No Cdt/Udt or No primary_key:', sync_data_sql)
    else:
        # 新增同步
        if 'Udt' in cols and primary_key != '':
            src_where_statement = "${SRC_INCR_FIELD} > ''${INCR_POINT}''"
            fields_mapping = '{"Udt": "udt"}'
            sync_data_sql = f"insert into manager.job_data_sync (src_schema_name, src_table_name, dst_schema_name, " \
                            f"dst_table_name, src_select_statement, src_where_statement, sync_mode, src_incr_field," \
                            f" dst_pk, fields_mapping, incr_point, src_type, src_db_name) values " \
                            f"('dbo', '{t_ss}', '{t_pg.split('.')[0]}', '{t_pg.split('.')[1]}', '{cols}', '"+ src_where_statement +"', 'merge', 'Udt'," \
                            f" '{primary_key}', '" + fields_mapping + f"', '1970-01-01', '{f_ss}', '{d_ss}')"
            print(sync_data_sql)
        elif 'Cdt' in cols and primary_key != '':
            src_where_statement = "${SRC_INCR_FIELD} > ''${INCR_POINT}''"
            fields_mapping = '{"Cdt": "cdt"}'
            sync_data_sql = f"insert into manager.job_data_sync (src_schema_name, src_table_name, dst_schema_name, " \
                            f"dst_table_name, src_select_statement, src_where_statement, sync_mode, src_incr_field," \
                            f" dst_pk, fields_mapping, incr_point, src_type, src_db_name) values " \
                            f"('dbo', '{t_ss}', '{t_pg.split('.')[0]}', '{t_pg.split('.')[1]}', '{cols}', '"+ src_where_statement +"', 'merge', 'Cdt'," \
                            f" '{primary_key}', '" + fields_mapping + f"', '1970-01-01', '{f_ss}', '{d_ss}')"
            print(sync_data_sql)
        else:
            src_where_statement = "${SRC_INCR_FIELD} > ''${INCR_POINT}''"
            sync_data_sql = f"insert into manager.job_data_sync (src_schema_name, src_table_name, dst_schema_name, " \
                            f"dst_table_name, src_select_statement, src_where_statement, sync_mode, src_incr_field," \
                            f" dst_pk, incr_point, src_type, src_db_name) values " \
                            f"('dbo', '{t_ss}', '{t_pg.split('.')[0]}', '{t_pg.split('.')[1]}', '{cols}', '"+ src_where_statement +"', 'full', '1'," \
                            f" '{primary_key}', '-1', '{f_ss}', '{d_ss}')"
            print('No Cdt/Udt or No primary_key:', sync_data_sql)

    simple_conn_pool = psycopg2.pool.SimpleConnectionPool(minconn=1, maxconn=10,
                                                          dbname=d_pg,
                                                          user=getConfig().get(f_pg, 'user'),
                                                          password=getConfig().get(f_pg, 'ps'),
                                                          host=getConfig().get(f_pg, 'ip'),
                                                          port=getConfig().get(f_pg, 'port'))
    conn = simple_conn_pool.getconn()
    with conn:
        cur = conn.cursor(cursor_factory=psycopg2.extras.RealDictCursor)
        cur.execute(sync_data_sql)
        conn.commit()


if __name__ == '__main__':
    f_ss = 'IMX'  # Server Name
    d_ss = 'CTO'  # SQL Server Database

    f_pg = 'IMX_PG'  # PostgreSQL Name
    d_pg = 'bdc'  # PostgreSQL Database
    # t_list = get_cdc_tableList()  # SQL Server Tablename
    t_list = ['DnCancelLog']
    flag = 'repair'  # repair:补数据，new:新增同步
    st = '2023-05-01'
    et = '2023-05-04'

    for t_ss in t_list:
        t_pg = f'fis.{d_ss.lower()}_{t_ss.lower()}'  # PostgreSQL Tablename
        # t_pg = f'scc.{t_ss.lower()}'
        metadata = get_mssql_metadata()
        print(metadata)
        print('------')
        print_sync_data(metadata)
        print('------')
        # create_pg_table(metadata)
        # print('------')
        # pg_comment(metadata)
