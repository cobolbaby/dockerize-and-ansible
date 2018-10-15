- 检查`LDAP`相关配置

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