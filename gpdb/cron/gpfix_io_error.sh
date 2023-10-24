#!/bin/bash

cd $MASTER_DATA_DIRECTORY/pg_log

awk -F, '/(invalid page in block|could not read block)/ {print $19}' gpdb-2023-*.csv | sed 's/.*base\/\([0-9]*\)\/\([0-9]*\).*seg\([0-9]*\).*/\1,\2,\3/' | sort | uniq -c | sort -nr
    151 884386,2028239,19
     26 863243,32130685,19
      9 863243,28252031,17
      7 863243,2013693,8
      3 863243,2021258,2
      1 863243,2014078,2

[gpadmin@gp6mdw pg_log]$ psql postgres -c  "select * from gp_segment_configuration where content in (19, 17, 8, 2, 6) order by content asc"
 dbid | content | role | preferred_role | mode | status | port  | hostname | address |                 datadir                 
------+---------+------+----------------+------+--------+-------+----------+---------+-----------------------------------------
   24 |       2 | m    | m              | s    | u      | 50002 | gp6sdw4  | gp6sdw4 | /disk3/gpdata/gpsegment/mirror/gpseg2
    4 |       2 | p    | p              | s    | u      | 40002 | gp6sdw1  | gp6sdw1 | /disk3/gpdata/gpsegment/primary/gpseg2
    8 |       6 | p    | p              | s    | u      | 40002 | gp6sdw2  | gp6sdw2 | /disk3/gpdata/gpsegment/primary/gpseg6
   28 |       6 | m    | m              | s    | u      | 50002 | gp6sdw5  | gp6sdw5 | /disk3/gpdata/gpsegment/mirror/gpseg6
   10 |       8 | p    | p              | s    | u      | 40000 | gp6sdw3  | gp6sdw3 | /disk1/gpdata/gpsegment/primary/gpseg8
   30 |       8 | m    | m              | s    | u      | 50000 | gp6sdw4  | gp6sdw4 | /disk1/gpdata/gpsegment/mirror/gpseg8
   39 |      17 | m    | m              | s    | u      | 50001 | gp6sdw2  | gp6sdw2 | /disk2/gpdata/gpsegment/mirror/gpseg17
   19 |      17 | p    | p              | s    | u      | 40001 | gp6sdw5  | gp6sdw5 | /disk2/gpdata/gpsegment/primary/gpseg17
   21 |      19 | m    | p              | n    | d      | 40003 | gp6sdw5  | gp6sdw5 | /disk4/gpdata/gpsegment/primary/gpseg19
   41 |      19 | p    | m              | n    | u      | 50003 | gp6sdw4  | gp6sdw4 | /disk4/gpdata/gpsegment/mirror/gpseg19
(10 rows)

[gpadmin@gp6mdw pg_log]$ psql postgres -c  "select * from gp_segment_configuration where content in (19, 17, 8, 2, 6) and preferred_role = 'p' order by content asc"
 dbid | content | role | preferred_role | mode | status | port  | hostname | address |                 datadir                 
------+---------+------+----------------+------+--------+-------+----------+---------+-----------------------------------------
    4 |       2 | p    | p              | s    | u      | 40002 | gp6sdw1  | gp6sdw1 | /disk3/gpdata/gpsegment/primary/gpseg2
    8 |       6 | p    | p              | s    | u      | 40002 | gp6sdw2  | gp6sdw2 | /disk3/gpdata/gpsegment/primary/gpseg6
   10 |       8 | p    | p              | s    | u      | 40000 | gp6sdw3  | gp6sdw3 | /disk1/gpdata/gpsegment/primary/gpseg8
   19 |      17 | p    | p              | s    | u      | 40001 | gp6sdw5  | gp6sdw5 | /disk2/gpdata/gpsegment/primary/gpseg17
   21 |      19 | m    | p              | n    | d      | 40003 | gp6sdw5  | gp6sdw5 | /disk4/gpdata/gpsegment/primary/gpseg19
(5 rows)

[gpadmin@gp6mdw pg_log]$ ssh gp6sdw1 pg_ctl -D /disk3/gpdata/gpsegment/primary/gpseg2 stop -m fast
waiting for server to shut down..... done
server stopped
[gpadmin@gp6mdw pg_log]$ ssh gp6sdw2 pg_ctl -D /disk3/gpdata/gpsegment/primary/gpseg6 stop -m fast
waiting for server to shut down..... done
server stopped
[gpadmin@gp6mdw pg_log]$ ssh gp6sdw3 pg_ctl -D /disk1/gpdata/gpsegment/primary/gpseg8 stop -m fast
waiting for server to shut down..... done
server stopped
[gpadmin@gp6mdw pg_log]$ ssh gp6sdw5 pg_ctl -D /disk2/gpdata/gpsegment/primary/gpseg17 stop -m fast
waiting for server to shut down..... done
server stopped
[gpadmin@gp6mdw pg_log]$ ssh gp6sdw5 pg_ctl -D /disk4/gpdata/gpsegment/primary/gpseg19 stop -m fast
waiting for server to shut down..... done
server stopped
[gpadmin@gp6mdw pg_log]$ psql postgres -c  "select * from gp_segment_configuration where content in (19, 17, 8, 2, 6) and preferred_role = 'p' order by content asc"
 dbid | content | role | preferred_role | mode | status | port  | hostname | address |                 datadir                 
------+---------+------+----------------+------+--------+-------+----------+---------+-----------------------------------------
    4 |       2 | m    | p              | n    | d      | 40002 | gp6sdw1  | gp6sdw1 | /disk3/gpdata/gpsegment/primary/gpseg2
    8 |       6 | m    | p              | n    | d      | 40002 | gp6sdw2  | gp6sdw2 | /disk3/gpdata/gpsegment/primary/gpseg6
   10 |       8 | m    | p              | n    | d      | 40000 | gp6sdw3  | gp6sdw3 | /disk1/gpdata/gpsegment/primary/gpseg8
   19 |      17 | m    | p              | n    | d      | 40001 | gp6sdw5  | gp6sdw5 | /disk2/gpdata/gpsegment/primary/gpseg17
   21 |      19 | m    | p              | n    | d      | 40003 | gp6sdw5  | gp6sdw5 | /disk4/gpdata/gpsegment/primary/gpseg19
(5 rows)

gprecoverseg -a

# 表重建
# select * from pg_database where oid = 863243 
# F6_BDC
# select gp_segment_id, oid::regclass, * from gp_dist_random('pg_class') 
# where relfilenode = 41710884 and gp_segment_id = 6;
# "mes.mes_trace"

# begin;
# create table ${table}_temp as select * from ${table};
# truncate ${table};
# insert into ${table} select * from ${table}_temp;
# drop table ${table}_temp;
# commit;
# alter table ${table} set DISTRIBUTED BY (?);

# begin;
# create table mes.mes_trace_temp as select * from mes.mes_trace;
# truncate mes.mes_trace;
# insert into mes.mes_trace select * from mes.mes_trace_temp;
# # INSERT 0 188863821
# drop table mes.mes_trace_temp;
# commit;

gprecoverseg -r -a
