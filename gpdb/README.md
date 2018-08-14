- `http_proxy`
```
Timeout on http://mirrorlist.centos.org/?release=7&arch=x86_64&repo=os&infra=container: (28, 'Resolving timedout after 30546 milliseconds')
```
- `which` command not found
```
********************************************************************************
Error: sed was not found in your path.
       sed is needed to run this installer.
       Please add sed to your path before running the installer again.
       Exiting installer.
********************************************************************************
```
- `systemctl`
```
Failed to get D-Bus connection: Operation not permitted
```
- `source` command don't work
```
环境变量未生效
```
- `ssh`,`scp`,`ip`,`less` command not found
```
[root@ITC180012 greenplum]# gpinitsystem -c config/gp_config
/usr/local/greenplum-db/./bin/lib/gp_bash_functions.sh: line 75: return: Problem in gp_bash_functions, command 'ssh' not found in COMMAND path. 
```
- `Unable to run as root`
```
[root@ITC180012 greenplum]# gpinitsystem -c config/gp_config
20180814:16:15:15:000516 gpinitsystem:ITC180012:root-[INFO]:-Environment variable $USER unset, will set to root
20180814:16:15:15:000516 gpinitsystem:ITC180012:root-[INFO]:-Environment variable $LOGNAME unset, will set to root
20180814:16:15:15:000516 gpinitsystem:ITC180012:root-[INFO]:-Checking configuration parameters, please wait...
20180814:16:15:15:gpinitsystem:ITC180012:root-[FATAL]:-Unable to run this script as root Script Exiting!
```
- `/etc/hosts`配置
```
[gpadmin@ITC180012 greenplum]$ gpinitsystem -c config/gp_config
20180814:16:18:31:000910 gpinitsystem:ITC180012:gpadmin-[INFO]:-Checking configuration parameters, please wait...
20180814:16:18:31:000910 gpinitsystem:ITC180012:gpadmin-[INFO]:-Reading Greenplum configuration file config/gp_config
20180814:16:18:31:000910 gpinitsystem:ITC180012:gpadmin-[INFO]:-Locale has not been set in config/gp_config, willset to default value
20180814:16:18:31:000910 gpinitsystem:ITC180012:gpadmin-[INFO]:-Locale set to en_US.utf8
20180814:16:18:31:000910 gpinitsystem:ITC180012:gpadmin-[WARN]:-Master hostname mdw does not match hostname output
20180814:16:18:31:000910 gpinitsystem:ITC180012:gpadmin-[INFO]:-Checking to see if mdw can be resolved on this host
ssh: Could not resolve hostname mdw: Name or service not known
ssh: Could not resolve hostname mdw: Name or service not known
20180814:16:18:31:000910 gpinitsystem:ITC180012:gpadmin-[FATAL]:-Master hostname in configuration file is mdw
20180814:16:18:31:000910 gpinitsystem:ITC180012:gpadmin-[FATAL]:-Operating system command returns ITC180012
20180814:16:18:31:000910 gpinitsystem:ITC180012:gpadmin-[FATAL]:-Unable to resolve mdw on this host
20180814:16:18:31:gpinitsystem:ITC180012:gpadmin-[FATAL]:-Master hostname in gpinitsystem configuration file mustbe mdw Script Exiting!
```
- `Directory Permission`
```
/bin/touch: cannot touch ‘/disk1/gpdata/gpmaster/tmp_file_test’: No such file or directory
20180814:16:47:20:gpinitsystem:ITC180012:gpadmin-[FATAL]:-Cannot write to /disk1/gpdata/gpmaster on master host  Script Exiting!
```

