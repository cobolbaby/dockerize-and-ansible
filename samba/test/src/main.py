#!/usr/bin/env python
# encoding:utf-8

from smb.SMBConnection import SMBConnection
from smb import smb_structs

smb_structs.SUPPORT_SMB2 = True

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
        for share in shares:
            if not share.isSpecial and share.name not in ['NETLOGON', 'SYSVOL']:
                shared_files = conn.listPath(share.name, '/')
                for shared_file in shared_files:
                    print(shared_file.filename)
    except Exception as e:
        print(f"Error listing files: {e}")

def main():
    username = 'dev'
    password = '111111'
    my_name = 'itc180012'
    remote_name = 'samba'
    remote_ip = '10.191.7.21'

    conn = connect_to_smb(username, password, my_name, remote_name, remote_ip)
    if conn:
        list_smb_files(conn)
        conn.close()

if __name__ == "__main__":
    main()
