#!/bin/bash

# 获取过期分区
pg_get_expired_partitions=$(cat <<-EOF
    WITH q_expired_part AS (
        select
            *,
            ((regexp_match(part_expr, \$$ TO \('(.*)'\)\$$))[1])::timestamp without time zone as part_end
        from
            (
                select
                    format('%I.%I', n.nspname, p.relname) as parent_name,
                    format('%I.%I', n.nspname, c.relname) as part_name,
                    pg_catalog.pg_get_expr(c.relpartbound, c.oid) as part_expr
                from
                    pg_class p
                    join pg_inherits i ON i.inhparent = p.oid
                    join pg_class c on c.oid = i.inhrelid
                    join pg_namespace n on n.oid = c.relnamespace
                where
                    p.relname = '${relname}'
                    and n.nspname = '${nspname}'
                    and p.relkind = 'p'
            ) x
    )
    SELECT
        -- format('DROP TABLE IF EXISTS %s', part_name) as sql_to_exec
        part_name
    FROM
        q_expired_part
    WHERE
        part_end < CURRENT_DATE - interval '2 months'
        and part_name !~* '(his|default|extra)$';
EOF
)

# 获取过期分区
pg_get_retention_partitions=$(cat <<-EOF
    select format('%I.%I', n.nspname, c.relname) as part_name
    from pg_class c join pg_namespace n on n.oid = c.relnamespace
    where c.relname like '${relname}%' and n.nspname = '${nspname}' 
    and c.relkind = 'r' and c.relispartition = false
    order by part_name asc
EOF
)

# 新建分区
pg_get_new_partitions=$(cat <<-EOF
    WITH q_last_part AS (
        select
            *,
            ((regexp_match(part_expr, \$$ TO \('(.*)'\)\$$))[1])::timestamp without time zone as last_part_end,
            ((regexp_match(part_expr, \$$ FROM \('(.*?)'\)\$$))[1])::timestamp without time zone as last_part_begin
        from
            (
                select
                    format('%I.%I', n.nspname, p.relname) as parent_name,
                    format('%I.%I', n.nspname, c.relname) as part_name,
                    pg_catalog.pg_get_expr(c.relpartbound, c.oid) as part_expr
                from
                    pg_class p
                    join pg_inherits i ON i.inhparent = p.oid
                    join pg_class c on c.oid = i.inhrelid
                    join pg_namespace n on n.oid = c.relnamespace
                where
                    p.relname = '${relname}'
                    and n.nspname = '${nspname}'
                    and p.relkind = 'p'
                    and c.relname !~* '(his|default|extra)$'
            ) x
        order by
            last_part_end desc
        limit
            1
    )
    SELECT
        parent_name,
        extract(year from last_part_end) as year,
        lpad((extract(month from last_part_end))::text, 2, '0') as month,
        last_part_end,
        last_part_end + (last_part_end - last_part_begin)::interval as next_part_end,
        format(
            \$$ CREATE TABLE IF NOT EXISTS %s_%s%s PARTITION OF %s FOR VALUES FROM ('%s') TO ('%s') \$$,
            parent_name,
            extract(year from last_part_end),
            lpad((extract(month from last_part_end))::text, 2, '0'),
            -- lpad((extract(day from last_part_end))::text, 2, '0'),
            parent_name,
            last_part_end,
            last_part_end + (last_part_end - last_part_begin)::interval
        ) AS sql_to_exec
    FROM
        q_last_part;
EOF
)