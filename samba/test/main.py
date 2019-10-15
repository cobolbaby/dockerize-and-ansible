#!/usr/bin/env python
# encoding:utf-8
from smb.SMBConnection import SMBConnection
from smb import smb_structs
smb_structs.SUPPORT_SMB2 = True

# username: 远程主机用户名  password: 远程主机密码
# my_name: 本机主机计算机名 remote_name: 远程主机计算机名

username = 'dev'
password = '111111'
my_name = 'itc180012'
remote_name = 'samba'

conn = SMBConnection(username, password, my_name, remote_name)
conn.connect('10.191.7.21', 139)

shares = conn.listShares()
for share in shares:
    if not share.isSpecial and share.name not in ['NETLOGON', 'SYSVOL']:
        sharedfiles = conn.listPath(share.name, '/')
        for sharedfile in sharedfiles:
            print(sharedfile.filename)

conn.close()
