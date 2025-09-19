from ftplib import FTP

ftp = FTP("127.0.0.1")
ftp.login("..", "...")

try:
    for name, facts in ftp.mlsd("."):
        print("支持 MLSD:", name, facts)
        break
except Exception as e:
    print("不支持 MLSD:", e)