- 检查LDAP配置是否正确

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

- `Unicorn does not come up (error 502) after hard restart of Docker server`

> https://github.com/sameersbn/docker-gitlab/issues/1305

- 检查Microsoft Exchange配置是否正确

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

- 检查GitLab服务是否正常

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