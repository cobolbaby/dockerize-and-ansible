#!/usr/bin/env python
# encoding:utf-8

from flask import Flask, jsonify, request
from smb.SMBConnection import SMBConnection
from smb import smb_structs
from functools import wraps
import re
import os

smb_structs.SUPPORT_SMB2 = True
app = Flask(__name__)

# ---------- 参数校验装饰器 ----------

def is_valid_ip(ip):
    return re.match(r'^(\d{1,3}\.){3}\d{1,3}$', ip) is not None and all(0 <= int(part) <= 255 for part in ip.split('.'))

def is_valid_port(port):
    return isinstance(port, int) and 0 < port <= 65535

validators = {
    "remote_ip": is_valid_ip,
    "port": is_valid_port,
}

def validate_json(required_fields):
    def decorator(func):
        @wraps(func)
        def wrapper(*args, **kwargs):
            if not request.is_json:
                return jsonify({"code": 400, "message": "Content-Type must be application/json"}), 400
            data = request.get_json()
            for field in required_fields:
                if field not in data:
                    return jsonify({"code": 400, "message": f"Missing parameter: {field}"}), 400
                if field in validators and not validators[field](data[field]):
                    return jsonify({"code": 400, "message": f"Invalid format for: {field}"}), 400
            return func(*args, **kwargs)
        return wrapper
    return decorator

# ---------- SMB 操作 ----------

def connect_to_smb(username, password, my_name, remote_name, remote_ip, port=139):
    try:
        conn = SMBConnection(username, password, my_name, remote_name, use_ntlm_v2=True)
        conn.connect(remote_ip, port)
        return conn
    except Exception as e:
        print(f"❌ Error connecting to SMB server: {e}")
        return None

def list_smb_files(conn, share_name, path='/'):
    try:
        entries = conn.listPath(share_name, path)
        return [f.filename for f in entries if not f.isDirectory and not f.filename.startswith('.')]
    except Exception as e:
        print(f"❌ Error listing files: {e}")
        return []

def download_file_optimized(conn, share_name, remote_path, file_name, chunk_size=4 * 1024 * 1024):
    try:
        remote_file_path = os.path.join(remote_path, file_name).replace('\\', '/')
        file_attr = conn.getAttributes(share_name, remote_file_path)
        file_size = file_attr.file_size

        local_path = os.path.join("downloads", file_name)
        os.makedirs("downloads", exist_ok=True)

        with open(local_path, 'wb') as f:
            offset = 0
            while offset < file_size:
                remaining = file_size - offset
                read_size = min(chunk_size, remaining)
                data = conn.retrieveFileFromOffset(share_name, remote_file_path, offset, read_size)
                f.write(data.read())
                offset += read_size
                print(f"⬇ {offset}/{file_size} bytes downloaded", end='\r')

        return {"file_name": file_name, "size": file_size, "local_path": local_path}
    except Exception as e:
        print(f"❌ Error during file download: {e}")
        return None

# ---------- API 路由 ----------

@app.route('/api/connect-smb', methods=['POST'])
@validate_json(["username", "password", "my_name", "remote_name", "remote_ip", "share_name"])
def connect_smb():
    data = request.get_json()
    conn = connect_to_smb(
        data["username"],
        data["password"],
        data["my_name"],
        data["remote_name"],
        data["remote_ip"],
        data.get("port", 139)
    )

    if conn:
        files = list_smb_files(conn, data["share_name"])
        conn.close()
        return jsonify({"code": 200, "message": "Connection successful", "files": files}), 200
    else:
        return jsonify({"code": 500, "message": "Failed to connect to SMB server"}), 500

@app.route('/api/download-smb-file', methods=['POST'])
@validate_json([
    "username", "password", "my_name", "remote_name", "remote_ip",
    "share_name", "remote_path", "file_name"
])
def download_smb_file():
    data = request.get_json()
    conn = connect_to_smb(
        data["username"],
        data["password"],
        data["my_name"],
        data["remote_name"],
        data["remote_ip"],
        data.get("port", 139)
    )

    if not conn:
        return jsonify({"code": 500, "message": "Failed to connect to SMB server"}), 500

    result = download_file_optimized(
        conn,
        data["share_name"],
        data["remote_path"],
        data["file_name"]
    )
    conn.close()

    if result:
        return jsonify({"code": 200, "message": "Download successful", "data": result}), 200
    else:
        return jsonify({"code": 500, "message": "Download failed"}), 500

# ---------- 启动服务 ----------

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=8080)
