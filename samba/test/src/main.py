#!/usr/bin/env python
# encoding:utf-8

from flask import Flask, jsonify, request
from smb.SMBConnection import SMBConnection
from smb import smb_structs
import time

smb_structs.SUPPORT_SMB2 = True

app = Flask(__name__)

def connect_to_smb(username, password, my_name, remote_name, remote_ip, port=139):
    try:
        conn = SMBConnection(username, password, my_name, remote_name)
        conn.connect(remote_ip, port)
        return conn
    except Exception as e:
        print(f"Error connecting to SMB server: {e}")
        return None

def list_smb_files(conn):
    try:
        shares = conn.listShares()
        files = []
        for share in shares:
            if not share.isSpecial and share.name not in ['NETLOGON', 'SYSVOL']:
                shared_files = conn.listPath(share.name, '/')
                for shared_file in shared_files:
                    files.append(shared_file.filename)
        return files
    except Exception as e:
        print(f"Error listing files: {e}")
        return []

@app.route('/api/connect-smb', methods=['POST'])
def connect_smb():
    data = request.json
    required_params = ["username", "password", "my_name", "remote_name", "remote_ip"]
    
    # Check for missing parameters
    for param in required_params:
        if param not in data:
            return jsonify({"code": 400, "message": f"Missing parameter: {param}"}), 400
    
    # Extract parameters
    username = data["username"]
    password = data["password"]
    my_name = data["my_name"]
    remote_name = data["remote_name"]
    remote_ip = data["remote_ip"]
    
    # Attempt connection
    conn = connect_to_smb(username, password, my_name, remote_name, remote_ip)
    if conn:
        files = list_smb_files(conn)
        conn.close()
        return jsonify({"code": 200, "message": "Connection successful", "data": files}), 200
    else:
        return jsonify({"code": 500, "message": "Failed to connect to SMB server"}), 500

@app.route('/api/slow-endpoint', methods=['GET'])
def slow_endpoint():
    # 模拟一个耗时的操作
    time.sleep(5)
    return jsonify({"code": 200, "message": "This request took 5 seconds to complete."}), 200

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=8080)

