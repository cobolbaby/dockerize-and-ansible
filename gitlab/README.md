[TOC]

# GitLab使用手册

## 故障定位以及常用操作

### 检查GitLab服务是否正常

```
root@gitlab:/# gitlab-ctl status
run: alertmanager: (pid 1359) 328s; run: log: (pid 1378) 328s
run: gitaly: (pid 1146) 333s; run: log: (pid 1181) 333s
run: gitlab-monitor: (pid 1283) 331s; run: log: (pid 1293) 331s
run: gitlab-workhorse: (pid 1114) 335s; run: log: (pid 1128) 334s
run: logrotate: (pid 714) 360s; run: log: (pid 1138) 334s
run: nginx: (pid 699) 361s; run: log: (pid 1133) 334s
run: node-exporter: (pid 1190) 332s; run: log: (pid 1200) 332s
run: postgres-exporter: (pid 1385) 327s; run: log: (pid 1397) 327s
run: postgresql: (pid 482) 400s; run: log: (pid 1096) 336s
run: prometheus: (pid 1317) 330s; run: log: (pid 1352) 329s
run: redis: (pid 447) 401s; run: log: (pid 1092) 337s
run: redis-exporter: (pid 1300) 331s; run: log: (pid 1310) 330s
run: sidekiq: (pid 677) 363s; run: log: (pid 1105) 335s
run: sshd: (pid 26) 412s; run: log: (pid 25) 412s
run: unicorn: (pid 644) 369s; run: log: (pid 1101) 336s
```

### 检查LDAP配置是否正确

```
root@gitlab:/# gitlab-rake gitlab:ldap:check
Checking LDAP ...

Server: ldapmain
LDAP authentication... Success
LDAP users with access to your GitLab server (only showing the first 100 results)
        DN: cn=itc-xxxx,ou=itc po,dc=itc,dc=inventec        sAMAccountName: ITC-000017-NB$
        DN: cn=itc-xxxx,ou=itc po,dc=itc,dc=inventec         sAMAccountName: ITC-950038-N$
        ...

Checking LDAP ... Finished
```

### 检查Microsoft Exchange配置是否正确

```
root@gitlab:/# gitlab-rails console
-------------------------------------------------------------------------------------
 GitLab:       11.1.4 (63daf37)
 GitLab Shell: 7.1.4
 postgresql:   9.6.8
-------------------------------------------------------------------------------------
Loading production environment (Rails 4.2.10)
irb(main):001:0> Notify.test_email('Zhang.Xing-Long@inventec.com', 'Message Subject', 'Message Body').deliver_now
```

### GitLab服务在主机重启之后亟待解决的问题

参考: [Unicorn does not come up (error 502) after hard restart of Docker server](https://github.com/sameersbn/docker-gitlab/issues/1305)


### LDAP认证失败问题定位

之前有同事反馈GitLab域账户认证总失败，借此机会定位一下究竟是GitLab存在bug还是域控服务器出的问题。

查看GitLab容器日志可以发现如下异常:

```
Started POST "/users/auth/ldapmain/callback" for 127.0.0.1 at 2019-05-08 10:02:05 +0000
Processing by OmniauthCallbacksController#failure as HTML
  Parameters: {"utf8"=>"~\~S", "authenticity_token"=>"[FILTERED]", "username"=>"ITC110014", "password"=>"[FILTERED]"}
```

从日志中可以看出是LDAP服务器返回异常，究竟是认证存在问题，还是传递的域账户参数存在问题(之前遇到过域账户密码不支持特殊字符的情况)，官方提供了一个验证方法: [Debug LDAP user filter with ldapsearch](https://docs.gitlab.com/ce/administration/auth/ldap.html#debug-ldap-user-filter-with-ldapsearch)

随便找台linux机器，执行如下验证操作:

```
sudo apt install ldap-utils
ldapsearch -H ldap://10.190.1.15:389 -D "cn=<USERNAME>,ou=itc users,dc=itc,dc=inventec" -w "<PASSWORD>" -b "DC=itc,DC=inventec" "" sAMAccountName
ldap_bind: Invalid credentials (49)
	additional info: 80090308: LdapErr: DSID-0C090421, comment: AcceptSecurityContext error, data 775, v23f0
```

上面异常提示说明了LDAP Server出现了异常。具体原因可参考:

- [Data codes related to 'LDAP: error code 49' with Microsoft Active Directory](https://www-01.ibm.com/support/docview.wss?uid=swg21290631)
- [Microsoft Active Directory（LDAP）连接常见错误代码](https://blog.csdn.net/chaijunkun/article/details/23695001)

### 仓库备份

- 短暂停服，拷贝数据目录
- 磁盘镜像
