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

# ⚙️ 配置本地时间（America/Denver 是 UTC+8）
LOCAL_TIMEZONE = pytz.timezone(os.getenv("TIMEZONE", "Asia/Shanghai"))

# 时间范围（本地时间）
START_TIME_STR = os.getenv("START_TIME", "2025-04-21 00:00:00")
END_TIME_STR   = os.getenv("END_TIME", "2025-04-22 00:00:00")
TIME_FORMAT = "%Y-%m-%d %H:%M:%S"

START_TIME = LOCAL_TIMEZONE.localize(datetime.strptime(START_TIME_STR, TIME_FORMAT))
END_TIME   = LOCAL_TIMEZONE.localize(datetime.strptime(END_TIME_STR, TIME_FORMAT))

# ========= 初始化 =========
client = Minio(
    MINIO_ENDPOINT,
    access_key=MINIO_ACCESS_KEY,
    secret_key=MINIO_SECRET_KEY,
    secure=False,
)

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

def is_within_time_range_by_name(obj_name: str) -> bool:
    dt = get_tsms_from_filename(obj_name)
    if not dt:
        return False
    return START_TIME <= dt <= END_TIME

def get_tsms_via_s3select(object_name):
    try:
        # https://github.com/minio/minio-py/blob/master/examples/select_object_content.py
        with client.select_object_content(
            BUCKET_NAME,
            object_name,
            SelectRequest(
                "SELECT * FROM S3Object WHERE lsn = '190025694841392'",
                ParquetInputSerialization(),
                CSVOutputSerialization(),
                request_progress=False,
            ),
        ) as result:
            print(f"S3 Select {object_name}:")
            for data in result.stream():
                line = data.decode()
                if line:
                    print(f"line: {line}")
            print(result.stats())
    except Exception as e:
        print(f"[!] S3 Select failed for {object_name}: {e}")
        raise e
    
for obj in client.list_objects(BUCKET_NAME, prefix=PREFIX, recursive=True):
    if not is_within_time_range_by_name(obj.object_name):
        continue
    
    get_tsms_via_s3select(obj.object_name)
