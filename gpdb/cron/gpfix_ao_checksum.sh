#!/bin/bash

<<comment
    -- 20220809:00:08:37:2802983 analyzedb:gp6mdw:gpadmin-[WARNING]:-ERROR:  block checksum does not match, expected 0xA4C4BE2F and found 0x190F0D26  (seg3 10.13.0.31:40003 pid=2201661)
    -- DETAIL:  Append-Only storage Small Content header: smallcontent_bytes_0_3 0x1902380F, smallcontent_bytes_4_7 0xF58026B4, headerKind = 1, executorBlockKind = 1, rowCount = 142, usingChecksums = true, header checksum 0x151CC6DB, block checksum 0xA4C4BE2F, dataLength 32684, compressedLength 9908, overallBlockLen 9928
    -- CONTEXT:  Scan of Append-Only Row-Oriented relation 'trace_components_1_prt_trace_components_31'. Append-Only segment file 'base/863243/2019277.1', block header offset in file = 202439744, bufferCount 22027

    psql postgres -c "select * from gp_segment_configuration where content = 2;"

    dbid | content | role | preferred_role | mode | status | port  | hostname | address |                datadir                 
    ------+---------+------+----------------+------+--------+-------+----------+---------+----------------------------------------
        4 |       2 | p    | p              | s    | u      | 40002 | gp6sdw1  | gp6sdw1 | /disk3/gpdata/gpsegment/primary/gpseg2
    24 |       2 | m    | m              | s    | u      | 50002 | gp6sdw4  | gp6sdw4 | /disk3/gpdata/gpsegment/mirror/gpseg2
    (2 rows)

    ssh gp6sdw1 md5sum /disk3/gpdata/gpsegment/primary/gpseg2/base/863243/2019115.1
    ssh gp6sdw4 md5sum /disk3/gpdata/gpsegment/mirror/gpseg2/base/863243/2019115.1

    scp gp6sdw4:/disk3/gpdata/gpsegment/mirror/gpseg2/base/863243/2019115.1 /tmp/
    scp /tmp/2019115.1 gp6sdw1:/disk3/gpdata/gpsegment/primary/gpseg2/base/863243/

    ssh gp6sdw1 md5sum /disk3/gpdata/gpsegment/primary/gpseg2/base/863243/2019115.1
    ssh gp6sdw4 md5sum /disk3/gpdata/gpsegment/mirror/gpseg2/base/863243/2019115.1

    rm /tmp/2019115.1 
comment

# 两个参数
segment_content=$1
segment_file=$2

# 判断参数是否存在
if [ -z "$segment_content" ] || [ -z "$segment_file" ]; then
    echo "Usage: $0 seg3 base/863243/2019277.1"
    exit 1
fi

# 获取 segment_id
segment_content_id=${segment_content:3}
echo "segment_content_id: $segment_content_id, segment_file: $segment_file"

segment_config=$(psql postgres -Atc "select address,datadir from gp_segment_configuration where content = ${segment_content_id} and role = 'p';")

# 判断 segment_config 是否存在
if [ -z "$segment_config" ]; then
    echo "primary segment config is empty"
    exit 2
fi

# https://stackoverflow.com/questions/10586153/how-to-split-a-string-into-an-array-in-bash
IFS='|' read -r -a segments <<< "$segment_config"
paddress="${segments[0]}"
pdatadir="${segments[1]}"
echo "primary segment address: ${paddress}, datadir: ${pdatadir}"

segment_config=$(psql postgres -Atc "select address,datadir from gp_segment_configuration where content = ${segment_content_id} and role = 'm';")

# https://stackoverflow.com/questions/10586153/how-to-split-a-string-into-an-array-in-bash
IFS='|' read -r -a segments <<< "$segment_config"
maddress="${segments[0]}"
mdatadir="${segments[1]}"
echo "mirror segment address: ${maddress}, datadir: ${mdatadir}"

# 解析 segment_file
f=(`echo $segment_file | tr '/' ' '`)
datoid=${f[1]}
relfilenode=${f[2]%%.*}

datname=$(psql postgres -Atc "select datname from pg_database where oid = ${datoid};")
relname=$(psql ${datname} -Atc "select oid::regclass from gp_dist_random('pg_class') where relfilenode = ${relfilenode} and gp_segment_id = ${segment_content_id};")

if [ -z "$relname" ]; then
    echo "relname is empty"
    exit 3
fi

echo ""
echo "please execute the following command in the gp6mdw container to fix ${relname} in ${datname}:"
echo ""

echo "ssh ${paddress} md5sum ${pdatadir}/${segment_file}"
echo "ssh ${maddress} md5sum ${mdatadir}/${segment_file}"

echo "scp ${maddress}:${mdatadir}/${segment_file} /tmp/"
echo "scp /tmp/$(basename ${mdatadir}/${segment_file}) ${paddress}:$(dirname ${pdatadir}/${segment_file})"

echo "ssh ${paddress} md5sum ${pdatadir}/${segment_file}"
echo "ssh ${maddress} md5sum ${mdatadir}/${segment_file}"

echo "rm /tmp/$(basename ${mdatadir}/${segment_file})"

echo "psql ${datname} -c \"analyse ${relname};\""
