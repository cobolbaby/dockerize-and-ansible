import json
import os
import re
from collections import defaultdict
from datetime import datetime, timedelta, timezone
from multiprocessing import Pool, cpu_count

import pyarrow.parquet as pq
import pytz
from dotenv import load_dotenv
from minio.error import S3Error
from minio.select import (CSVOutputSerialization, ParquetInputSerialization,
                          SelectRequest)

from minio import Minio

# ========= 配置 =========
load_dotenv()

MINIO_ENDPOINT = os.getenv("MINIO_ENDPOINT", "")
MINIO_ACCESS_KEY = os.getenv("MINIO_ACCESS_KEY", "")
MINIO_SECRET_KEY = os.getenv("MINIO_SECRET_KEY", "")
BUCKET_NAME = os.getenv("BUCKET_NAME", "public")
PREFIX = os.getenv("PREFIX", "/")
LOCAL_CACHE_DIR = "./cache"
META_FILE = "meta.json"

# ⚙️ 配置本地时间（America/Denver 是 UTC+8）
LOCAL_TIMEZONE = pytz.timezone(os.getenv("TIMEZONE", "Asia/Shanghai"))

# 时间范围（本地时间）
START_TIME_STR = os.getenv("START_TIME", "2025-04-18 00:00:00")
END_TIME_STR   = os.getenv("END_TIME", "2025-04-19 00:00:00")
TIME_FORMAT = "%Y-%m-%d %H:%M:%S"

START_TIME = LOCAL_TIMEZONE.localize(datetime.strptime(START_TIME_STR, TIME_FORMAT))
END_TIME   = LOCAL_TIMEZONE.localize(datetime.strptime(END_TIME_STR, TIME_FORMAT))

# ========= 初始化 =========
os.makedirs(LOCAL_CACHE_DIR, exist_ok=True)

client = Minio(
    MINIO_ENDPOINT,
    access_key=MINIO_ACCESS_KEY,
    secret_key=MINIO_SECRET_KEY,
    secure=False,
)

# ========= 载入元信息 =========
if os.path.exists(META_FILE):
    with open(META_FILE, "r") as f:
        etag_map = json.load(f)
else:
    etag_map = {}

def save_etag_map():
    with open(META_FILE, "w") as f:
        json.dump(etag_map, f, indent=2)

# ========= 时间提取函数 =========
def get_tsms_from_filename(name: str) -> datetime | None:
    # 匹配类型1: fact_cpu_sno_parts-2025-04-17 02:00:24.757272.parquet
    m1 = re.search(r"-(\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2})", name)
    if m1:
        dt = datetime.strptime(m1.group(1), "%Y-%m-%d %H:%M:%S")
        return LOCAL_TIMEZONE.localize(dt)

    # 匹配类型2: fact_cpu_sno_parts-1744952414718.parquet
    m2 = re.search(r"-(\d{13,})\.parquet", name)
    if m2:
        ts_ms = int(m2.group(1))
        dt = datetime.fromtimestamp(ts_ms / 1000.0, tz=timezone.utc)
        return dt.astimezone(LOCAL_TIMEZONE)

    return None

def parse_tsms(ts_value):
    if isinstance(ts_value, str):
        return LOCAL_TIMEZONE.localize(datetime.strptime(ts_value, TIME_FORMAT))
    elif isinstance(ts_value, datetime):
        if ts_value.tzinfo is None:
            return LOCAL_TIMEZONE.localize(ts_value)
        return ts_value.astimezone(LOCAL_TIMEZONE)
    else:
        raise ValueError(f"不支持的 tsms 格式: {ts_value}")

def get_tsms_via_s3select(object_name):
    try:
        # https://github.com/minio/minio-py/blob/master/examples/select_object_content.py
        with client.select_object_content(
            BUCKET_NAME,
            object_name,
            SelectRequest(
                "SELECT MIN(tsms), MAX(tsms) FROM S3Object",
                ParquetInputSerialization(),
                CSVOutputSerialization(),
                request_progress=False,
            ),
        ) as result:
            for data in result.stream():
                line = data.decode().strip()
                if line:
                    min_tsms, max_tsms = line.split(',')
                    
                    return datetime.fromtimestamp(int(min_tsms) / 1000.0, tz=timezone.utc), \
                            datetime.fromtimestamp(int(max_tsms) / 1000.0, tz=timezone.utc)
    except Exception as e:
        print(f"[!] S3 Select failed for {object_name}: {e}")
        raise e
    
    return None, None

def is_within_time_range_by_name(obj_name: str) -> bool:
    dt = get_tsms_from_filename(obj_name)
    if not dt:
        return False
    return START_TIME <= dt <= END_TIME

def is_within_time_range(obj_name):
    try:
        # 获取第一条和最后一条 tsms
        first_ts, last_ts = get_tsms_via_s3select(obj_name)

        if not first_ts or not last_ts:
            return False

        # 时间范围是否有交集
        return not (last_ts < START_TIME or first_ts > END_TIME)

    except Exception as e:
        print(f"[!] tsms 判断失败，尝试使用文件名时间: {e}")
        return is_within_time_range_by_name(obj_name)

def is_file_changed(obj):
    return etag_map.get(obj.object_name) != obj.etag

def fetch_file(obj):
    local_path = os.path.join(LOCAL_CACHE_DIR, obj.object_name.replace("/", "_"))
    client.fget_object(BUCKET_NAME, obj.object_name, local_path)
    return local_path

# ========= 数据提取 =========
def batch_process_tsms(batch):
    local_counter = defaultdict(int)
    tsms_column = batch.column("tsms")
    for value in tsms_column:
        if value.is_valid is False:
            continue
        
        ts = value.as_py()
        ts = parse_tsms(ts)

        hour_key = ts.strftime("%Y%m%d%H00")
        local_counter[hour_key] += 1
    return local_counter

def merge_counters(counters):
    merged = defaultdict(int)
    for counter in counters:
        for k, v in counter.items():
            merged[k] += v
    return merged

def extract_hour_distribution_by_tsms(file_path):
    counters = []
    try:
        pf = pq.ParquetFile(file_path)
        num_row_groups = pf.num_row_groups
        num_workers = min(cpu_count(), 8)

        # 每个 row group 分配给一个进程
        with Pool(processes=num_workers) as pool:
            batches = [pf.read_row_group(i, columns=["tsms"]) for i in range(num_row_groups)]
            counters = pool.map(batch_process_tsms, batches)

        return merge_counters(counters)

    except Exception as e:
        print(f"[!] Failed to process {file_path}: {e}")
        return defaultdict(int)

def extract_hour_distribution_by_row_count(parquet_path: str) -> dict:
    filename = os.path.basename(parquet_path)
    dt = get_tsms_from_filename(filename)
    if not dt:
        return {}

    # 减去1小时表示“上一个周期”
    dt_adjusted = dt - timedelta(hours=1)
    hour_key = dt_adjusted.strftime("%Y%m%d%H00")

    pf = pq.ParquetFile(parquet_path)
    return {hour_key: pf.metadata.num_rows}

# ========= 主逻辑 =========
total_stats = defaultdict(int)

for obj in client.list_objects(BUCKET_NAME, prefix=PREFIX, recursive=True):

    if not is_within_time_range(obj.object_name):
        continue

    local_file_path = os.path.join(LOCAL_CACHE_DIR, obj.object_name)
    os.makedirs(os.path.dirname(local_file_path), exist_ok=True)

    file_exists = os.path.exists(local_file_path)
    changed = is_file_changed(obj)

    if not changed and file_exists:
        print(f"Use cached: {obj.object_name}")
    else:
        print(f"Fetching: {obj.object_name}")
        try:
            client.fget_object(BUCKET_NAME, obj.object_name, local_file_path)
            etag_map[obj.object_name] = obj.etag
        except S3Error as e:
            print(f"[MinIO Error]: {e}")
            continue

    try:
        table = pq.read_table(local_file_path)
        if "tsms" in table.schema.names:
            stats = extract_hour_distribution_by_tsms(local_file_path)
        else:
            stats = extract_hour_distribution_by_row_count(local_file_path)
    except Exception as e:
        print(f"[!] Failed to process {obj.object_name}: {e}")
        continue

    for hour, count in stats.items():
        total_stats[hour] += count

save_etag_map()

# ========= 输出结果 =========
print("\n📊 tsms 每小时分布（本地时区）:")
for hour in sorted(total_stats):
    print(f"{hour}: {total_stats[hour]}")
