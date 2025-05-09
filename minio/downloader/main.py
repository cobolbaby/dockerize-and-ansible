import os
from threading import Lock
from minio import Minio
from concurrent.futures import ThreadPoolExecutor
import psycopg2
import zipfile

# 配置参数
MINIO_CONFIG = {
    "endpoint": "minio.example.com",
    "access_key": "your_access_key",
    "secret_key": "your_secret_key",
    "secure": True,
    "bucket_name": "your_bucket_name"
}

DB_CONFIG = {
    "host": "localhost",
    "port": 5432,
    "user": "your_db_user",
    "password": "your_db_password",
    "dbname": "your_db_name"
}

TARGET_DIR = "./downloaded_files"
ZIP_PATH = "./downloaded_files.zip"
MAX_WORKERS = 8

# 全局计数器和锁（用于线程安全）
success_count = 0
failure_count = 0
counter_lock = Lock()

# 获取下载文件列表（从数据库查询）
def get_object_list_from_db():
    conn = psycopg2.connect(**DB_CONFIG)
    cursor = conn.cursor()
    cursor.execute("set optimizer_enable_hashjoin = off;")
    cursor.execute("""
        select 
            case when az.archivedpath is null then p.path 
                else az.archivedpath || '/' || p.path
            END as object_name
        from inframinio.pic_info p
            left join inframinio.archive_zip_info az on p.s3site_id = az.s3site_id and p.path = az.path and substring(md5(p.path),1,8) = az.path_hash
        where wc in ('05', '0B') 
        and test_time between '2025-04-23 00:00' and '2025-04-24 00:00'
        and size > 1024*1024*10
        limit 1000;
    """)
    rows = cursor.fetchall()
    cursor.close()
    conn.close()
    return [row[0] for row in rows]


# 下载单个对象
def download_object(client, bucket, object_name, target_dir):
    global success_count, failure_count
    file_path = os.path.join(target_dir, object_name)
    os.makedirs(os.path.dirname(file_path), exist_ok=True)
    
    try:
        client.fget_object(bucket, object_name, file_path)
        print(f"✅ Downloaded: {object_name}")
        with counter_lock:
            success_count += 1
    except Exception as e:
        print(f"❌ Error downloading {object_name}: {e}")
        with counter_lock:
            failure_count += 1


# 并行批量下载
def batch_download(client, object_names, target_dir, bucket, max_workers=8):
    with ThreadPoolExecutor(max_workers=max_workers) as executor:
        for object_name in object_names:
            executor.submit(download_object, client, bucket, object_name, target_dir)


# 可选：打包为 ZIP 文件
def zip_directory(source_dir, zip_path):
    with zipfile.ZipFile(zip_path, 'w', zipfile.ZIP_DEFLATED) as zipf:
        for foldername, _, filenames in os.walk(source_dir):
            for filename in filenames:
                file_path = os.path.join(foldername, filename)
                arcname = os.path.relpath(file_path, source_dir)
                zipf.write(file_path, arcname)
    print(f"Zipped to {zip_path}")


if __name__ == "__main__":
    # 初始化 MinIO 客户端
    client = Minio(
        MINIO_CONFIG["endpoint"],
        access_key=MINIO_CONFIG["access_key"],
        secret_key=MINIO_CONFIG["secret_key"],
        secure=MINIO_CONFIG["secure"]
    )

    print("Fetching object list from DB...")
    object_list = get_object_list_from_db()

    print(f"Starting download of {len(object_list)} files...")
    batch_download(client, object_list, TARGET_DIR, MINIO_CONFIG["bucket_name"], MAX_WORKERS)

    print(f"\n✅ Total Success: {success_count}")
    print(f"❌ Total Failed:  {failure_count}")

    # 可选 ZIP 打包
    # zip_directory(TARGET_DIR, ZIP_PATH)
