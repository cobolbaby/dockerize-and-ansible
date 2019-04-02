
### cloud-init初始化系统配置

CoreOS的配置初始化可以使用`coreos-cloudinit`工具，具体操作如下:

```bash
sudo coreos-cloudinit --from-file ./prod-cloud-init.yml
sudo systemctl daemon-reload
sudo systemctl restart sshd.socket
# netstat -nltp
```

### 支持Ansible远程操作

可能出现的错误提示:

```bash
gpdb-sdw1 | FAILED! => {
    "changed": false, 
    "module_stderr": "Shared connection to 10.3.205.91 closed.\r\n", 
    "module_stdout": "Traceback (most recent call last):\r\n  File \"/home/prod/.ansible/tmp/ansible-tmp-1554121958.86-105214325853796/ping.py\", line 133, in <module>\r\n    exitcode = invoke_module(module, zipped_mod, ANSIBALLZ_PARAMS)\r\n  File \"/home/prod/.ansible/tmp/ansible-tmp-1554121958.86-105214325853796/ping.py\", line 37, in invoke_module\r\n    p = subprocess.Popen(['/opt/bin/python', module], env=os.environ, shell=False, stdout=subprocess.PIPE, stderr=subprocess.PIPE, stdin=subprocess.PIPE)\r\n  File \"/usr/local/lib/python2.7/subprocess.py\", line 394, in __init__\r\n    errread, errwrite)\r\n  File \"/usr/local/lib/python2.7/subprocess.py\", line 1047, in _execute_child\r\n    raise child_exception\r\nOSError: [Errno 2] No such file or directory\r\n", 
    "msg": "MODULE FAILURE", 
    "rc": 1
}
```

错误原因: python容器中并没有`/opt/bin/python`执行档，所以可以定制一下python镜像

```Dockerfile
FROM python:2.7-slim
RUN mkdir -p /opt/bin/ && ln -sf /usr/local/bin/python /opt/bin/python
```