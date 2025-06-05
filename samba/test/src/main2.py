import os
import yaml
from smb.SMBConnection import SMBConnection

def load_config(path='config.yaml'):
    with open(path, 'r', encoding='utf-8') as f:
        return yaml.safe_load(f)

def download_file_optimized(conn, share_name, remote_path, file_name, chunk_size=4 * 1024 * 1024):
    remote_file_path = os.path.join(remote_path, file_name).replace('\\', '/')
    file_attr = conn.getAttributes(share_name, remote_file_path)
    file_size = file_attr.file_size

    print(f"📦 开始下载 {file_name}，文件大小：{file_size} 字节，块大小：{chunk_size} 字节")

    with open(file_name, 'wb') as f:
        offset = 0
        while offset < file_size:
            remaining = file_size - offset
            read_size = min(chunk_size, remaining)
            data = conn.retrieveFileFromOffset(share_name, remote_file_path, offset, read_size)
            f.write(data.read())
            offset += read_size
            print(f"   ⬇ 已下载 {offset}/{file_size} 字节", end='\r')
    
    print(f"\n✅ 下载完成：{file_name}")

def main():
    config = load_config()
    smb_conf = config.get('smb', {})

    ip = smb_conf.get('ip')
    username = smb_conf.get('username')
    password = smb_conf.get('password')
    my_name = smb_conf.get('my_name')
    remote_name = smb_conf.get('remote_name')
    share_name = smb_conf.get('share_name')
    remote_path = smb_conf.get('remote_path')
    file_name = smb_conf.get('file_name')

    conn = SMBConnection(username, password, my_name, remote_name, use_ntlm_v2=True)
    if not conn.connect(ip):
        print("❌ 无法连接到 SMB 服务端")
        return

    try:
        files = conn.listPath(share_name, remote_path)
        file_list = [f.filename for f in files if not f.isDirectory and not f.filename.startswith('.')]
        print("📂 当前目录文件列表：")
        for fname in file_list:
            print(" -", fname)

        if not file_list:
            print("❌ 当前目录没有可下载的文件。")
            return

        if not file_name:
            file_name = file_list[0]
            print(f"⚠️ 未配置文件名，默认下载第一个文件: {file_name}")

        download_file_optimized(conn, share_name, remote_path, file_name)

    except Exception as e:
        print(f"❌ 下载失败: {e}")

if __name__ == "__main__":
    main()
