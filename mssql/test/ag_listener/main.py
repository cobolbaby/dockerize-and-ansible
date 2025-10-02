#!/usr/bin/env python3
"""
ag_listener.py

使用 pymssql 持续对 SQL Server AG Listener 发起 CRUD 请求，观察 Listener/连接在物理主机 IP 切换时的表现。
"""

import argparse
import contextlib
import logging
import random
import string
import sys
import threading
import time
import uuid
from datetime import datetime, timezone
from typing import Any, Callable, List, Optional

import pymssql

# ------------------ Logging ------------------
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] [%(threadName)s] %(message)s",
    handlers=[logging.StreamHandler(sys.stdout)],
)
logger = logging.getLogger("ag_listener")

# ------------------ SQL Client ------------------
class SqlClient:
    def __init__(self, host: str, port: int, database: str, user: str, password: str, max_retries: int = 5):
        self.host = host
        self.port = port
        self.database = database
        self.user = user
        self.password = password
        self.max_retries = max_retries
        self.conn: Optional[pymssql.Connection] = None
        self.lock = threading.RLock()

    def connect(self) -> None:
        attempt = 0
        while True:
            try:
                logger.info(f"尝试连接 {self.host}:{self.port}/{self.database} ...")
                conn = pymssql.connect(
                    server=self.host,
                    port=self.port,
                    database=self.database,
                    user=self.user,
                    password=self.password,
                    login_timeout=5,
                    timeout=5,
                )
                self.conn = conn
                logger.info(f"连接成功: {self.host}:{self.port}/{self.database}")
                return
            except Exception as e:
                attempt += 1
                backoff = min(10, 2 ** attempt)
                logger.warning(f"连接失败: {e}, 重试 {attempt}/{self.max_retries}，等待 {backoff}s")
                time.sleep(backoff)
                if attempt >= self.max_retries:
                    logger.error("超过最大重试次数，继续永久重试")
                    attempt = 0

    def ensure_conn(self) -> None:
        with self.lock:
            if self.conn is None:
                self.connect()
                return
            try:
                with self.conn.cursor() as cur:
                    cur.execute("SELECT 1")
                    cur.fetchone()
            except Exception:
                logger.warning("连接失效，重新建立连接")
                self.close()
                self.connect()

    def close(self) -> None:
        with self.lock:
            if self.conn:
                try:
                    self.conn.close()
                except Exception:
                    pass
                finally:
                    self.conn = None

    def run_with_retry(self, fn: Callable[..., Any], *args, **kwargs) -> Any:
        attempt = 0
        while True:
            try:
                self.ensure_conn()
                with self.lock:
                    return fn(self.conn, *args, **kwargs)
            except Exception as e:
                attempt += 1
                logger.warning(f"数据库操作异常: {e}, 重试 {attempt}")
                self.close()
                time.sleep(min(10, 2 ** attempt))
                if attempt >= self.max_retries:
                    logger.error("连续失败过多，休眠 30s 再继续")
                    time.sleep(30)
                    attempt = 0


# ------------------ CRUD Helpers ------------------
def with_cursor(fn: Callable[..., Any]) -> Callable[..., Any]:
    """装饰器，提供自动游标管理"""
    def wrapper(conn: pymssql.Connection, *args, **kwargs):
        with conn.cursor() as cur:
            return fn(cur, *args, **kwargs)
    return wrapper

@with_cursor
def do_create(cur: pymssql.Cursor) -> str:
    new_id = str(uuid.uuid4())
    payload = "[C] " + "".join(random.choices(string.ascii_letters + string.digits, k=32))
    now = datetime.now(timezone.utc)
    cur.execute("INSERT INTO dbo.ag_test(id, data, updated_at) VALUES (%s, %s, %s)", (new_id, payload, now))
    cur.connection.commit()
    logger.info(f"CREATE id={new_id}")
    return new_id

@with_cursor
def do_read(cur: pymssql.Cursor, sample_id: Optional[str] = None) -> Optional[str]:
    if sample_id:
        cur.execute("SELECT id, data, updated_at FROM dbo.ag_test WHERE id=%s", (sample_id,))
    else:
        cur.execute("SELECT TOP 1 id, data, updated_at FROM dbo.ag_test ORDER BY NEWID()")
    row = cur.fetchone()
    if row:
        logger.info(f"READ id={row[0]} updated_at={row[2]}")
        return row[0]
    logger.info("READ no row")
    return None

@with_cursor
def do_update(cur: pymssql.Cursor, target_id: str) -> int:
    new_payload = "[U] " + "".join(random.choices(string.ascii_letters + string.digits, k=16))
    now = datetime.now(timezone.utc)
    cur.execute("UPDATE dbo.ag_test SET data=%s, updated_at=%s WHERE id=%s", (new_payload, now, target_id))
    cur.connection.commit()
    logger.info(f"UPDATE id={target_id} affected={cur.rowcount}")
    return cur.rowcount

@with_cursor
def do_delete(cur: pymssql.Cursor, target_id: str) -> int:
    cur.execute("DELETE FROM dbo.ag_test WHERE id=%s", (target_id,))
    cur.connection.commit()
    logger.info(f"DELETE id={target_id} affected={cur.rowcount}")
    return cur.rowcount


# ------------------ Worker ------------------
def worker_main(client: SqlClient, interval: float, seed: Optional[int] = None) -> None:
    rnd = random.Random(seed or int(time.time()) ^ threading.get_ident())
    last_ids: List[str] = []
    ops = ["create", "read", "update", "delete"]
    weights = [30, 40, 20, 10]

    while True:
        try:
            op = rnd.choices(ops, weights=weights)[0]
            if op == "create":
                cid = client.run_with_retry(do_create)
                if cid:
                    last_ids.append(cid)
                    last_ids = last_ids[-500:]
            elif op == "read":
                sid = rnd.choice(last_ids) if last_ids and rnd.random() < 0.5 else None
                client.run_with_retry(do_read, sid)
            elif op == "update" and last_ids:
                client.run_with_retry(do_update, rnd.choice(last_ids))
            elif op == "delete" and last_ids:
                client.run_with_retry(do_delete, last_ids.pop(rnd.randrange(len(last_ids))))
            time.sleep(max(0, interval * (0.6 + rnd.random() * 0.8)))
        except KeyboardInterrupt:
            logger.info("收到中断，退出线程")
            break
        except Exception as e:
            logger.exception(f"未捕获异常: {e}")
            time.sleep(1)


# ------------------ CLI ------------------
def parse_args() -> argparse.Namespace:
    p = argparse.ArgumentParser(description="SQL Server AG Listener 测试工具")
    p.add_argument("--server", required=True, help="AG Listener 主机名或 IP")
    p.add_argument("--port", type=int, default=1433)
    p.add_argument("--database", required=True)
    p.add_argument("--uid", required=True)
    p.add_argument("--pwd", required=True)
    p.add_argument("--workers", type=int, default=1)
    p.add_argument("--interval", type=float, default=0.5)
    return p.parse_args()


def main() -> None:
    args = parse_args()
    clients: List[SqlClient] = []

    threads: List[threading.Thread] = []
    for i in range(args.workers):
        client = SqlClient(args.server, args.port, args.database, args.uid, args.pwd)
        clients.append(client)
        t = threading.Thread(target=worker_main, args=(client, args.interval, i),
                             daemon=True, name=f"worker-{i}")
        threads.append(t)
        t.start()

    try:
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        logger.info("主进程中断，准备退出")
    finally:
        for client in clients:
            client.close()
        time.sleep(1)


if __name__ == "__main__":
    main()
