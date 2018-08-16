## 说明

### 配置修改

- **cloud-init**

CoreOS的初始配置走`cloud-init`方式，配置文件在用户目录下的`cloud-config.yml`

- **常规方式**

```
$ sudo mkdir -p /etc/systemd/system/sshd.socket.d/
$ sudo vi /etc/systemd/system/sshd.socket.d/10-sshd-listen-ports.conf
[Socket]
ListenStream=
ListenStream=10022
$ sudo systemctl daemon-reload
$ sudo systemctl restart sshd.socket
```