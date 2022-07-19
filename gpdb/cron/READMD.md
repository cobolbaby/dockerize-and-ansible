- 无效索引

```sql

-- https://gpdb.docs.pivotal.io/6-20/ref_guide/system_catalogs/pg_stat_tables.html

CREATE VIEW gp_toolkit.gp_stat_all_indexes AS
SELECT
    s.relid,
    s.indexrelid,
    s.schemaname,
    s.relname,
    s.indexrelname,
    m.idx_scan,
    m.idx_tup_read,
    m.idx_tup_fetch
FROM
    (SELECT
         relid,
         indexrelid,
         schemaname,
         relname,
         indexrelname,
         sum(idx_scan) as idx_scan,
         sum(idx_tup_read) as idx_tup_read,
         sum(idx_tup_fetch) as idx_tup_fetch
     FROM gp_dist_random('pg_stat_all_indexes')
     WHERE relid >= 16384
     GROUP BY relid, indexrelid, schemaname, relname, indexrelname
     UNION ALL
     SELECT *
     FROM pg_stat_all_indexes
     WHERE relid < 16384) m, pg_stat_all_indexes s
WHERE m.indexrelid = s.indexrelid;


CREATE VIEW gp_toolkit.gp_stat_sys_indexes AS 
    SELECT * FROM gp_stat_all_indexes
    WHERE schemaname IN ('pg_catalog', 'information_schema') OR
          schemaname ~ '^pg_toast';


CREATE VIEW gp_toolkit.gp_stat_user_indexes AS 
    SELECT * FROM gp_stat_all_indexes
    WHERE schemaname NOT IN ('pg_catalog', 'information_schema') AND
          schemaname !~ '^pg_toast';


CREATE VIEW gp_toolkit.gp_stat_all_tables AS
SELECT
    s.relid,
    s.schemaname,
    s.relname,
    m.seq_scan,
    m.seq_tup_read,
    m.idx_scan,
    m.idx_tup_fetch,
    m.n_tup_ins,
    m.n_tup_upd,
    m.n_tup_del,
    m.n_tup_hot_upd,
    m.n_live_tup,
    m.n_dead_tup,
    s.n_mod_since_analyze,
    s.last_vacuum,
    s.last_autovacuum,
    s.last_analyze,
    s.last_autoanalyze,
    s.vacuum_count,
    s.autovacuum_count,
    s.analyze_count,
    s.autoanalyze_count
FROM
    (SELECT
         relid,
         schemaname,
         relname,
         sum(seq_scan) as seq_scan,
         sum(seq_tup_read) as seq_tup_read,
         sum(idx_scan) as idx_scan,
         sum(idx_tup_fetch) as idx_tup_fetch,
         sum(n_tup_ins) as n_tup_ins,
         sum(n_tup_upd) as n_tup_upd,
         sum(n_tup_del) as n_tup_del,
         sum(n_tup_hot_upd) as n_tup_hot_upd,
         sum(n_live_tup) as n_live_tup,
         sum(n_dead_tup) as n_dead_tup,
         max(n_mod_since_analyze) as n_mod_since_analyze,
         max(last_vacuum) as last_vacuum,
         max(last_autovacuum) as last_autovacuum,
         max(last_analyze) as last_analyze,
         max(last_autoanalyze) as last_autoanalyze,
         max(vacuum_count) as vacuum_count,
         max(autovacuum_count) as autovacuum_count,
         max(analyze_count) as analyze_count,
         max(autoanalyze_count) as autoanalyze_count
     FROM gp_dist_random('pg_stat_all_tables')
     WHERE relid >= 16384
     GROUP BY relid, schemaname, relname
     UNION ALL
     SELECT *
     FROM pg_stat_all_tables
     WHERE relid < 16384) m, pg_stat_all_tables s
 WHERE m.relid = s.relid;


CREATE VIEW gp_toolkit.gp_stat_sys_tables AS 
    SELECT * FROM gp_stat_all_tables
    WHERE schemaname IN ('pg_catalog', 'information_schema') OR
          schemaname ~ '^pg_toast';


CREATE VIEW gp_toolkit.gp_stat_user_tables AS 
    SELECT * FROM gp_stat_all_tables
    WHERE schemaname NOT IN ('pg_catalog', 'information_schema') AND
          schemaname !~ '^pg_toast';


-- 获取无效索引

select s.* from gp_stat_user_indexes s join pg_index i on s.indexrelid = i.indexrelid 
where s.idx_scan = 0 and not i.indisprimary and not i.indisunique and s.schemaname !~ '^pg_temp'
order by schemaname,relname

-- 循环获取索引大小，超过阀值则开始清理

select soisize/1024/1024/1024 as size_gb,* from gp_toolkit.gp_size_of_index
where  soitableschemaname = 'dw' and soitablename = 'fact_pca_log'
order by soisize desc;

-- 以下 SQL 报错

select s.*,pg_relation_size(s.indexrelid) as size from gp_stat_user_indexes s join pg_index i on s.indexrelid = i.indexrelid 
where s.idx_scan = 0 and not i.indisprimary and not i.indisunique and s.schemaname !~ '^pg_temp'
order by schemaname,relname
```

- 归档分区

```sql

-- 判断分区合理性

SELECT parrelid::regclass,
CASE WHEN parkind = 'r' THEN 'range'
     ELSE 'list'
END
FROM pg_partition;

-- 获取历史分区

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
        WHERE i.inhparent = 'ict.ictlogtestpart_ao_old'::regclass
    ) x
where part_name !~ '_extra$'
order by
    pstart asc

-- 归档历史分区

-- 如果归档的是冷数据，_old 表，当下暂时不用了，等有诉求的时候再导入，可以考虑将一些无数据的分区清理掉，然后再进行备份，避免不必要的小文件产生，_old表进行 truncate 操作

-- 正删除，倒删除，遇到有数据的情况则停止删除。

-- 如果切换的数据一般不会访问，但保不齐访问一下，用 S3 外部表，但一定要留意 SQL 的写法

-- 如果切换的数据每周还低频访问，此时用 HDD 承载这种大表会比较合适

-- 附加功能: 删除预创建的历史分区，反正也不会插入新数据，留着也没用，删除预创建的未来分区，没必要保留那么多










-- gpcheckcloud -c "s3://infra-oss-fis-archive.ipt.inventec.net/greenplum/F3_BDC/ict/ config=/home/gpadmin/s3/s3.conf"

-- 创建可写外部表，数据插入，Drop表定义
CREATE WRITABLE EXTERNAL TABLE ict.ictlogtestpart_ao_old_ext (LIKE ict.ictlogtestpart_ao_old_1_prt_80)
   LOCATION('s3://infra-oss-fis-archive.ipt.inventec.net/greenplum/F3_BDC/ict/ictlogtestpart_ao_old_1_prt_80/ config=/home/gpadmin/s3/s3.conf')
   FORMAT 'csv';

insert into ict.ictlogtestpart_ao_old_ext select * from ict.ictlogtestpart_ao_old_1_prt_80;

-- explain select * from ict.ictlogtestpart_ao_old_ext limit 1;

-- ERROR:  cannot read from a WRITABLE external table
-- HINT:  Create the table as READABLE instead.
-- SQL state: 42809

-- explain update ict.ictlogtestpart_ao_old_ext set devicetype = '3071' where transactionid = 'MISV2_3a6591c0-ba26-11ea-8398-5bee266d5e4e' 

-- ERROR:  cannot update or delete from external relation "ictlogtestpart_ao_old_ext"
-- SQL state: 0A000

DROP EXTERNAL TABLE ict.ictlogtestpart_ao_old_ext;

CREATE EXTERNAL TABLE ict.ictlogtestpart_ao_old_1_prt_80_ext (LIKE ict.ictlogtestpart_ao_old_1_prt_80)
   LOCATION('s3://infra-oss-fis-archive.ipt.inventec.net/greenplum/F3_BDC/ict/ictlogtestpart_ao_old_1_prt_80/ config=/home/gpadmin/s3/s3.conf')
   FORMAT 'csv';

explain analyse select * from ict.ictlogtestpart_ao_old_1_prt_80_ext limit 100;

-- "Limit  (cost=0.00..498.41 rows=5 width=551) (actual time=3828.707..4148.273 rows=100 loops=1)"
-- "  ->  Gather Motion 20:1  (slice1; segments: 20)  (cost=0.00..498.36 rows=100 width=551) (actual time=3828.703..4148.201 rows=100 loops=1)"
-- "        ->  Limit  (cost=0.00..498.22 rows=5 width=551) (actual time=3826.685..5803.318 rows=100 loops=1)"
-- "              ->  External Scan on ictlogtestpart_ao_old_1_prt_80_ext  (cost=0.00..446.98 rows=50000 width=551) (actual time=3826.684..3827.545 rows=100 loops=1)"
-- "Planning time: 12.444 ms"
-- "  (slice0)    Executor memory: 241K bytes."
-- "  (slice1)    Executor memory: 170K bytes avg x 20 workers, 170K bytes max (seg0)."
-- "Memory used:  204800kB"
-- "Optimizer: Pivotal Optimizer (GPORCA)"
-- "Execution time: 6601.587 ms"

explain analyse select * from ict.ictlogtestpart_ao_old_1_prt_80 limit 100;

-- "Limit  (cost=0.00..5062.57 rows=5 width=199) (actual time=1.773..1.914 rows=100 loops=1)"
-- "  ->  Gather Motion 20:1  (slice1; segments: 20)  (cost=0.00..5062.55 rows=100 width=199) (actual time=1.770..1.873 rows=100 loops=1)"
-- "        ->  Limit  (cost=0.00..5062.50 rows=5 width=199) (actual time=0.418..0.439 rows=100 loops=1)"
-- "              ->  Seq Scan on ictlogtestpart_ao_old_1_prt_80  (cost=0.00..1544.47 rows=9504613 width=199) (actual time=0.417..0.427 rows=100 loops=1)"
-- "Planning time: 23.852 ms"
-- "  (slice0)    Executor memory: 183K bytes."
-- "  (slice1)    Executor memory: 242K bytes avg x 20 workers, 242K bytes max (seg0)."
-- "Memory used:  204800kB"
-- "Optimizer: Pivotal Optimizer (GPORCA)"
-- "Execution time: 18.661 ms"

explain analyse select * from ict.ictlogtestpart_ao_old_1_prt_80_ext where transactionid = 'MISV2_3a6591c0-ba26-11ea-8398-5bee266d5e4e' limit 100;

-- "Limit  (cost=0.00..467.73 rows=5 width=509) (actual time=5362.004..5387.132 rows=100 loops=1)"
-- "  ->  Gather Motion 20:1  (slice1; segments: 20)  (cost=0.00..467.68 rows=100 width=509) (actual time=5362.001..5387.112 rows=100 loops=1)"
-- "        ->  Limit  (cost=0.00..467.56 rows=5 width=509) (actual time=5359.039..5385.464 rows=100 loops=1)"
-- "              ->  External Scan on ictlogtestpart_ao_old_1_prt_80_ext  (cost=0.00..467.56 rows=20000 width=509) (actual time=5359.037..5363.671 rows=100 loops=1)"
-- "                    Filter: ((transactionid)::text = 'MISV2_3a6591c0-ba26-11ea-8398-5bee266d5e4e'::text)"
-- "Planning time: 15.059 ms"
-- "  (slice0)    Executor memory: 242K bytes."
-- "  (slice1)    Executor memory: 170K bytes avg x 20 workers, 170K bytes max (seg0)."
-- "Memory used:  204800kB"
-- "Optimizer: Pivotal Optimizer (GPORCA)"
-- "Execution time: 103975.311 ms"

explain analyse select * from ict.ictlogtestpart_ao_old_1_prt_80 where transactionid = 'MISV2_3a6591c0-ba26-11ea-8398-5bee266d5e4e' limit 100;

-- "Limit  (cost=0.00..1857.31 rows=5 width=199) (actual time=3.949..4.588 rows=100 loops=1)"
-- "  ->  Gather Motion 20:1  (slice1; segments: 20)  (cost=0.00..1857.29 rows=100 width=199) (actual time=3.944..4.570 rows=100 loops=1)"
-- "        ->  Limit  (cost=0.00..1857.24 rows=5 width=199) (actual time=1.082..1.709 rows=100 loops=1)"
-- "              ->  Seq Scan on ictlogtestpart_ao_old_1_prt_80  (cost=0.00..1857.24 rows=203 width=199) (actual time=1.080..1.683 rows=100 loops=1)"
-- "                    Filter: ((transactionid)::text = 'MISV2_3a6591c0-ba26-11ea-8398-5bee266d5e4e'::text)"
-- "Planning time: 42.326 ms"
-- "  (slice0)    Executor memory: 183K bytes."
-- "  (slice1)    Executor memory: 242K bytes avg x 20 workers, 242K bytes max (seg0)."
-- "Memory used:  204800kB"
-- "Optimizer: Pivotal Optimizer (GPORCA)"
-- "Execution time: 15105.148 ms"

ALTER TABLE ict.ictlogtestpart_ao_old ALTER PARTITION ictlogtestpart_ao_old_1_prt_80 
   EXCHANGE PARTITION ictlogtestpart_ao_old_1_prt_80 
   WITH TABLE ict.ictlogtestpart_ao_old_1_prt_80_ext WITHOUT VALIDATION;

-- 删除原表
DROP TABLE ict.ictlogtestpart_ao_old_1_prt_80_ext;

```

- 可以删除的数据　

```sql
select pg_size_pretty(pg_total_relation_size(c.oid)) size, n.nspname,c.relname
from pg_class c
join pg_namespace n on c.relnamespace = n.oid
where relname ~ '_(del|clean)$' or n.nspname ~ '_del$'
order by pg_total_relation_size(c.oid) desc
```
