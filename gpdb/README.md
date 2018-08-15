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
环境变量未生效，写入`/etc/profile`
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
- `sshd`
```
[gpadmin@mdw greenplum]$ gpinitsystem -c config/gpinitsystem_config 
20180815:14:28:55:000070 gpinitsystem:mdw:gpadmin-[INFO]:-Checking configuration parameters, please wait...
20180815:14:28:55:000070 gpinitsystem:mdw:gpadmin-[INFO]:-Reading Greenplum configuration file config/gpinitsystem_config
20180815:14:28:55:000070 gpinitsystem:mdw:gpadmin-[INFO]:-Locale has not been set in config/gpinitsystem_config, will set to default value
20180815:14:28:55:000070 gpinitsystem:mdw:gpadmin-[INFO]:-Locale set to en_US.utf8
20180815:14:28:55:000070 gpinitsystem:mdw:gpadmin-[INFO]:-No DATABASE_NAME set, will exit following template1 updates
20180815:14:28:55:000070 gpinitsystem:mdw:gpadmin-[INFO]:-MASTER_MAX_CONNECT not set, will set to default value 250
20180815:14:28:55:000070 gpinitsystem:mdw:gpadmin-[INFO]:-Detected a single host GPDB array build, reducing value of BATCH_DEFAULT from 60 to 4
20180815:14:28:55:000070 gpinitsystem:mdw:gpadmin-[INFO]:-Checking configuration parameters, Completed
20180815:14:28:55:000070 gpinitsystem:mdw:gpadmin-[INFO]:-Commencing multi-home checks, please wait...
.ssh: connect to host sdw1 port 22: Connection refused
[FATAL]:-Remote command to host sdw1 failed to get value of hostname
[FATAL]:-Check to see that you have setup trusted remote ssh on all hosts
20180815:14:28:55:gpinitsystem:mdw:gpadmin-[FATAL]:-Unable to get hostname output for sdw1 Script Exiting!
```
- `ssh_host_rsa_key` not exists
```
[root@mdw greenplum]# /usr/sbin/sshd
Could not load host key: /etc/ssh/ssh_host_rsa_key
Could not load host key: /etc/ssh/ssh_host_ecdsa_key
Could not load host key: /etc/ssh/ssh_host_ed25519_key
sshd: no hostkeys available -- exiting.
```
- 没做互信的下场
```
[gpadmin@mdw greenplum]$ gpinitsystem -c config/gpinitsystem_config 
20180815:15:17:18:003928 gpinitsystem:mdw:gpadmin-[INFO]:-Checking configuration parameters, please wait...
20180815:15:17:18:003928 gpinitsystem:mdw:gpadmin-[INFO]:-Reading Greenplum configuration file config/gpinitsystem_config
20180815:15:17:18:003928 gpinitsystem:mdw:gpadmin-[INFO]:-Locale has not been set in config/gpinitsystem_config, will set to default value
20180815:15:17:18:003928 gpinitsystem:mdw:gpadmin-[INFO]:-Locale set to en_US.utf8
20180815:15:17:18:003928 gpinitsystem:mdw:gpadmin-[INFO]:-No DATABASE_NAME set, will exit following template1 updates
20180815:15:17:18:003928 gpinitsystem:mdw:gpadmin-[INFO]:-MASTER_MAX_CONNECT not set, will set to default value 250
20180815:15:17:18:003928 gpinitsystem:mdw:gpadmin-[INFO]:-Detected a single host GPDB array build, reducing value of BATCH_DEFAULT from 60 to 4
20180815:15:17:18:003928 gpinitsystem:mdw:gpadmin-[INFO]:-Checking configuration parameters, Completed
20180815:15:17:18:003928 gpinitsystem:mdw:gpadmin-[INFO]:-Commencing multi-home checks, please wait...
.gpadmin@sdw1's password: 

20180815:15:17:26:003928 gpinitsystem:mdw:gpadmin-[INFO]:-Configuring build for standard array
20180815:15:17:26:003928 gpinitsystem:mdw:gpadmin-[INFO]:-Commencing multi-home checks, Completed
20180815:15:17:27:003928 gpinitsystem:mdw:gpadmin-[INFO]:-Building primary segment instance array, please wait...
.gpadmin@sdw1's password: 
gpadmin@sdw1's password: 

20180815:15:17:38:003928 gpinitsystem:mdw:gpadmin-[INFO]:-Checking Master host
20180815:15:17:38:003928 gpinitsystem:mdw:gpadmin-[INFO]:-Checking new segment hosts, please wait...
gpadmin@sdw1's password: 
gpadmin@mdw's password: 
gpadmin@mdw's password: 
gpadmin@sdw1's password: 
.gpadmin@sdw1's password: 
20180815:15:17:50:gpinitsystem:mdw:gpadmin-[FATAL]:-Instance directory /data/greenplum/primary/gpseg0 exists on segment instance sdw1 Script Exiting!
[gpadmin@mdw greenplum]$ gpinitsystem -c config/gpinitsystem_config 
20180815:15:18:20:004491 gpinitsystem:mdw:gpadmin-[INFO]:-Checking configuration parameters, please wait...
20180815:15:18:20:004491 gpinitsystem:mdw:gpadmin-[INFO]:-Reading Greenplum configuration file config/gpinitsystem_config
20180815:15:18:20:004491 gpinitsystem:mdw:gpadmin-[INFO]:-Locale has not been set in config/gpinitsystem_config, will set to default value
20180815:15:18:20:004491 gpinitsystem:mdw:gpadmin-[INFO]:-Locale set to en_US.utf8
20180815:15:18:20:004491 gpinitsystem:mdw:gpadmin-[INFO]:-No DATABASE_NAME set, will exit following template1 updates
20180815:15:18:20:004491 gpinitsystem:mdw:gpadmin-[INFO]:-MASTER_MAX_CONNECT not set, will set to default value 250
20180815:15:18:20:004491 gpinitsystem:mdw:gpadmin-[INFO]:-Detected a single host GPDB array build, reducing value of BATCH_DEFAULT from 60 to 4
20180815:15:18:20:004491 gpinitsystem:mdw:gpadmin-[INFO]:-Checking configuration parameters, Completed
20180815:15:18:20:004491 gpinitsystem:mdw:gpadmin-[INFO]:-Commencing multi-home checks, please wait...
.gpadmin@sdw1's password: 

20180815:15:18:32:004491 gpinitsystem:mdw:gpadmin-[INFO]:-Configuring build for standard array
20180815:15:18:32:004491 gpinitsystem:mdw:gpadmin-[INFO]:-Commencing multi-home checks, Completed
20180815:15:18:32:004491 gpinitsystem:mdw:gpadmin-[INFO]:-Building primary segment instance array, please wait...
.gpadmin@sdw1's password: 
gpadmin@sdw1's password: 

20180815:15:18:37:004491 gpinitsystem:mdw:gpadmin-[INFO]:-Checking Master host
20180815:15:18:37:004491 gpinitsystem:mdw:gpadmin-[INFO]:-Checking new segment hosts, please wait...
gpadmin@sdw1's password: 
gpadmin@mdw's password: 
gpadmin@sdw1's password: 
.gpadmin@sdw1's password: 
gpadmin@sdw1's password: 
gpadmin@sdw1's password: 
gpadmin@sdw1's password: 

20180815:15:19:04:004491 gpinitsystem:mdw:gpadmin-[INFO]:-Checking new segment hosts, Completed
20180815:15:19:04:004491 gpinitsystem:mdw:gpadmin-[INFO]:-Greenplum Database Creation Parameters
20180815:15:19:04:004491 gpinitsystem:mdw:gpadmin-[INFO]:---------------------------------------
20180815:15:19:04:004491 gpinitsystem:mdw:gpadmin-[INFO]:-Master Configuration
20180815:15:19:04:004491 gpinitsystem:mdw:gpadmin-[INFO]:---------------------------------------
20180815:15:19:04:004491 gpinitsystem:mdw:gpadmin-[INFO]:-Master instance name       = Inventec Greenplum
20180815:15:19:04:004491 gpinitsystem:mdw:gpadmin-[INFO]:-Master hostname            = mdw
20180815:15:19:04:004491 gpinitsystem:mdw:gpadmin-[INFO]:-Master port                = 5432
20180815:15:19:04:004491 gpinitsystem:mdw:gpadmin-[INFO]:-Master instance dir        = /data/greenplum/master/gpseg-1
20180815:15:19:04:004491 gpinitsystem:mdw:gpadmin-[INFO]:-Master LOCALE              = en_US.utf8
20180815:15:19:04:004491 gpinitsystem:mdw:gpadmin-[INFO]:-Greenplum segment prefix   = gpseg
20180815:15:19:04:004491 gpinitsystem:mdw:gpadmin-[INFO]:-Master Database            = 
20180815:15:19:04:004491 gpinitsystem:mdw:gpadmin-[INFO]:-Master connections         = 250
20180815:15:19:04:004491 gpinitsystem:mdw:gpadmin-[INFO]:-Master buffers             = 128000kB
20180815:15:19:04:004491 gpinitsystem:mdw:gpadmin-[INFO]:-Segment connections        = 750
20180815:15:19:04:004491 gpinitsystem:mdw:gpadmin-[INFO]:-Segment buffers            = 128000kB
20180815:15:19:04:004491 gpinitsystem:mdw:gpadmin-[INFO]:-Checkpoint segments        = 8
20180815:15:19:04:004491 gpinitsystem:mdw:gpadmin-[INFO]:-Encoding                   = UNICODE
20180815:15:19:04:004491 gpinitsystem:mdw:gpadmin-[INFO]:-Postgres param file        = Off
20180815:15:19:04:004491 gpinitsystem:mdw:gpadmin-[INFO]:-Initdb to be used          = /usr/local/greenplum-db/./bin/initdb
20180815:15:19:05:004491 gpinitsystem:mdw:gpadmin-[INFO]:-GP_LIBRARY_PATH is         = /usr/local/greenplum-db/./lib
20180815:15:19:05:004491 gpinitsystem:mdw:gpadmin-[INFO]:-Ulimit check               = Passed
20180815:15:19:05:004491 gpinitsystem:mdw:gpadmin-[INFO]:-Array host connect type    = Single hostname per node
20180815:15:19:05:004491 gpinitsystem:mdw:gpadmin-[INFO]:-Master IP address [1]      = ::1
20180815:15:19:05:004491 gpinitsystem:mdw:gpadmin-[INFO]:-Master IP address [2]      = 10.190.5.110
20180815:15:19:05:004491 gpinitsystem:mdw:gpadmin-[INFO]:-Master IP address [3]      = 172.17.0.1
20180815:15:19:05:004491 gpinitsystem:mdw:gpadmin-[INFO]:-Master IP address [4]      = fe80::42:6bff:fe5c:4786
20180815:15:19:05:004491 gpinitsystem:mdw:gpadmin-[INFO]:-Master IP address [5]      = fe80::77bb:612e:f06e:62db
20180815:15:19:05:004491 gpinitsystem:mdw:gpadmin-[INFO]:-Standby Master             = Not Configured
20180815:15:19:05:004491 gpinitsystem:mdw:gpadmin-[INFO]:-Primary segment #          = 1
20180815:15:19:05:004491 gpinitsystem:mdw:gpadmin-[INFO]:-Total Database segments    = 1
20180815:15:19:05:004491 gpinitsystem:mdw:gpadmin-[INFO]:-Trusted shell              = ssh
20180815:15:19:05:004491 gpinitsystem:mdw:gpadmin-[INFO]:-Number segment hosts       = 1
20180815:15:19:05:004491 gpinitsystem:mdw:gpadmin-[INFO]:-Mirroring config           = OFF
20180815:15:19:05:004491 gpinitsystem:mdw:gpadmin-[INFO]:----------------------------------------
20180815:15:19:05:004491 gpinitsystem:mdw:gpadmin-[INFO]:-Greenplum Primary Segment Configuration
20180815:15:19:05:004491 gpinitsystem:mdw:gpadmin-[INFO]:----------------------------------------
20180815:15:19:05:004491 gpinitsystem:mdw:gpadmin-[INFO]:-sdw1 	/data/greenplum/primary/gpseg0 	20000 	2 	0
Continue with Greenplum creation Yy/Nn>
y
20180815:15:19:08:004491 gpinitsystem:mdw:gpadmin-[INFO]:-Building the Master instance database, please wait...
20180815:15:19:14:004491 gpinitsystem:mdw:gpadmin-[INFO]:-Starting the Master in admin mode
gpadmin@mdw's password: 
20180815:15:19:34:004491 gpinitsystem:mdw:gpadmin-[INFO]:-Commencing parallel build of primary segment instances
20180815:15:19:34:004491 gpinitsystem:mdw:gpadmin-[INFO]:-Spawning parallel processes    batch [1], please wait...
.
20180815:15:19:34:004491 gpinitsystem:mdw:gpadmin-[INFO]:-Waiting for parallel processes batch [1], please wait...
gpadmin@sdw1's password: ................................................
gpadmin@sdw1's password: .
Permission denied, please try again.
gpadmin@sdw1's password: 
Permission denied, please try again.
gpadmin@sdw1's password: 
Permission denied (publickey,gssapi-keyex,gssapi-with-mic,password).

20180815:15:20:53:004491 gpinitsystem:mdw:gpadmin-[INFO]:------------------------------------------------
20180815:15:20:53:004491 gpinitsystem:mdw:gpadmin-[INFO]:-Parallel process exit status
20180815:15:20:53:004491 gpinitsystem:mdw:gpadmin-[INFO]:------------------------------------------------
20180815:15:20:53:004491 gpinitsystem:mdw:gpadmin-[INFO]:-Total processes marked as completed           = 0
20180815:15:20:53:004491 gpinitsystem:mdw:gpadmin-[INFO]:-Total processes marked as killed              = 0
20180815:15:20:53:004491 gpinitsystem:mdw:gpadmin-[WARN]:-Total processes marked as failed              = 1 <<<<<
20180815:15:20:53:004491 gpinitsystem:mdw:gpadmin-[INFO]:------------------------------------------------
20180815:15:20:53:004491 gpinitsystem:mdw:gpadmin-[FATAL]:-Errors generated from parallel processes
20180815:15:20:53:004491 gpinitsystem:mdw:gpadmin-[INFO]:-Dumped contents of status file to the log file
20180815:15:20:53:004491 gpinitsystem:mdw:gpadmin-[INFO]:-Building composite backout file
20180815:15:20:53:gpinitsystem:mdw:gpadmin-[FATAL]:-Failures detected, see log file /home/gpadmin/gpAdminLogs/gpinitsystem_20180815.log for more detail Script Exiting!
20180815:15:20:53:004491 gpinitsystem:mdw:gpadmin-[WARN]:-Script has left Greenplum Database in an incomplete state
20180815:15:20:53:004491 gpinitsystem:mdw:gpadmin-[WARN]:-Run command /bin/bash /home/gpadmin/gpAdminLogs/backout_gpinitsystem_gpadmin_20180815_151820 to remove these changes
20180815:15:20:53:004491 gpinitsystem:mdw:gpadmin-[INFO]:-Start Function BACKOUT_COMMAND
20180815:15:20:53:004491 gpinitsystem:mdw:gpadmin-[INFO]:-End Function BACKOUT_COMMAND

```
- 互信
```
gpssh-exkeys -f config/hostlist
```
- 安装成功提示
```
[gpadmin@mdw greenplum]$ gpinitsystem -c config/gpinitsystem_config
20180815:15:36:31:009096 gpinitsystem:mdw:gpadmin-[INFO]:-Checking configuration parameters, please wait...
20180815:15:36:31:009096 gpinitsystem:mdw:gpadmin-[INFO]:-Reading Greenplum configuration file config/gpinitsystem_config
20180815:15:36:31:009096 gpinitsystem:mdw:gpadmin-[INFO]:-Locale has not been set in config/gpinitsystem_config, will set to default value
20180815:15:36:31:009096 gpinitsystem:mdw:gpadmin-[INFO]:-Locale set to en_US.utf8
20180815:15:36:31:009096 gpinitsystem:mdw:gpadmin-[INFO]:-No DATABASE_NAME set, will exit following template1 updates
20180815:15:36:31:009096 gpinitsystem:mdw:gpadmin-[INFO]:-MASTER_MAX_CONNECT not set, will set to default value 250
20180815:15:36:31:009096 gpinitsystem:mdw:gpadmin-[INFO]:-Detected a single host GPDB array build, reducing value of BATCH_DEFAULT from 60 to 4
20180815:15:36:31:009096 gpinitsystem:mdw:gpadmin-[INFO]:-Checking configuration parameters, Completed
20180815:15:36:31:009096 gpinitsystem:mdw:gpadmin-[INFO]:-Commencing multi-home checks, please wait...
.
20180815:15:36:31:009096 gpinitsystem:mdw:gpadmin-[INFO]:-Configuring build for standard array
20180815:15:36:31:009096 gpinitsystem:mdw:gpadmin-[INFO]:-Commencing multi-home checks, Completed
20180815:15:36:31:009096 gpinitsystem:mdw:gpadmin-[INFO]:-Building primary segment instance array, please wait...
.
20180815:15:36:32:009096 gpinitsystem:mdw:gpadmin-[INFO]:-Checking Master host
20180815:15:36:32:009096 gpinitsystem:mdw:gpadmin-[INFO]:-Checking new segment hosts, please wait...
.
20180815:15:36:33:009096 gpinitsystem:mdw:gpadmin-[INFO]:-Checking new segment hosts, Completed
20180815:15:36:33:009096 gpinitsystem:mdw:gpadmin-[INFO]:-Greenplum Database Creation Parameters
20180815:15:36:33:009096 gpinitsystem:mdw:gpadmin-[INFO]:---------------------------------------
20180815:15:36:33:009096 gpinitsystem:mdw:gpadmin-[INFO]:-Master Configuration
20180815:15:36:33:009096 gpinitsystem:mdw:gpadmin-[INFO]:---------------------------------------
20180815:15:36:33:009096 gpinitsystem:mdw:gpadmin-[INFO]:-Master instance name       = Inventec Greenplum
20180815:15:36:33:009096 gpinitsystem:mdw:gpadmin-[INFO]:-Master hostname            = mdw
20180815:15:36:33:009096 gpinitsystem:mdw:gpadmin-[INFO]:-Master port                = 5432
20180815:15:36:33:009096 gpinitsystem:mdw:gpadmin-[INFO]:-Master instance dir        = /data/greenplum/master/gpseg-1
20180815:15:36:33:009096 gpinitsystem:mdw:gpadmin-[INFO]:-Master LOCALE              = en_US.utf8
20180815:15:36:33:009096 gpinitsystem:mdw:gpadmin-[INFO]:-Greenplum segment prefix   = gpseg
20180815:15:36:33:009096 gpinitsystem:mdw:gpadmin-[INFO]:-Master Database            = 
20180815:15:36:34:009096 gpinitsystem:mdw:gpadmin-[INFO]:-Master connections         = 250
20180815:15:36:34:009096 gpinitsystem:mdw:gpadmin-[INFO]:-Master buffers             = 128000kB
20180815:15:36:34:009096 gpinitsystem:mdw:gpadmin-[INFO]:-Segment connections        = 750
20180815:15:36:34:009096 gpinitsystem:mdw:gpadmin-[INFO]:-Segment buffers            = 128000kB
20180815:15:36:34:009096 gpinitsystem:mdw:gpadmin-[INFO]:-Checkpoint segments        = 8
20180815:15:36:34:009096 gpinitsystem:mdw:gpadmin-[INFO]:-Encoding                   = UNICODE
20180815:15:36:34:009096 gpinitsystem:mdw:gpadmin-[INFO]:-Postgres param file        = Off
20180815:15:36:34:009096 gpinitsystem:mdw:gpadmin-[INFO]:-Initdb to be used          = /usr/local/greenplum-db/./bin/initdb
20180815:15:36:34:009096 gpinitsystem:mdw:gpadmin-[INFO]:-GP_LIBRARY_PATH is         = /usr/local/greenplum-db/./lib
20180815:15:36:34:009096 gpinitsystem:mdw:gpadmin-[INFO]:-Ulimit check               = Passed
20180815:15:36:34:009096 gpinitsystem:mdw:gpadmin-[INFO]:-Array host connect type    = Single hostname per node
20180815:15:36:34:009096 gpinitsystem:mdw:gpadmin-[INFO]:-Master IP address [1]      = ::1
20180815:15:36:34:009096 gpinitsystem:mdw:gpadmin-[INFO]:-Master IP address [2]      = 10.190.5.110
20180815:15:36:34:009096 gpinitsystem:mdw:gpadmin-[INFO]:-Master IP address [3]      = 172.17.0.1
20180815:15:36:34:009096 gpinitsystem:mdw:gpadmin-[INFO]:-Master IP address [4]      = fe80::42:6bff:fe5c:4786
20180815:15:36:34:009096 gpinitsystem:mdw:gpadmin-[INFO]:-Master IP address [5]      = fe80::77bb:612e:f06e:62db
20180815:15:36:34:009096 gpinitsystem:mdw:gpadmin-[INFO]:-Standby Master             = Not Configured
20180815:15:36:34:009096 gpinitsystem:mdw:gpadmin-[INFO]:-Primary segment #          = 1
20180815:15:36:34:009096 gpinitsystem:mdw:gpadmin-[INFO]:-Total Database segments    = 1
20180815:15:36:34:009096 gpinitsystem:mdw:gpadmin-[INFO]:-Trusted shell              = ssh
20180815:15:36:34:009096 gpinitsystem:mdw:gpadmin-[INFO]:-Number segment hosts       = 1
20180815:15:36:34:009096 gpinitsystem:mdw:gpadmin-[INFO]:-Mirroring config           = OFF
20180815:15:36:34:009096 gpinitsystem:mdw:gpadmin-[INFO]:----------------------------------------
20180815:15:36:34:009096 gpinitsystem:mdw:gpadmin-[INFO]:-Greenplum Primary Segment Configuration
20180815:15:36:34:009096 gpinitsystem:mdw:gpadmin-[INFO]:----------------------------------------
20180815:15:36:34:009096 gpinitsystem:mdw:gpadmin-[INFO]:-sdw1 	/data/greenplum/primary/gpseg0 	20000 	2 	0
Continue with Greenplum creation Yy/Nn>
Y
20180815:15:36:37:009096 gpinitsystem:mdw:gpadmin-[INFO]:-Building the Master instance database, please wait...
20180815:15:36:43:009096 gpinitsystem:mdw:gpadmin-[INFO]:-Starting the Master in admin mode
20180815:15:36:57:009096 gpinitsystem:mdw:gpadmin-[INFO]:-Commencing parallel build of primary segment instances
20180815:15:36:57:009096 gpinitsystem:mdw:gpadmin-[INFO]:-Spawning parallel processes    batch [1], please wait...
.
20180815:15:36:57:009096 gpinitsystem:mdw:gpadmin-[INFO]:-Waiting for parallel processes batch [1], please wait...
...........................
20180815:15:37:24:009096 gpinitsystem:mdw:gpadmin-[INFO]:------------------------------------------------
20180815:15:37:24:009096 gpinitsystem:mdw:gpadmin-[INFO]:-Parallel process exit status
20180815:15:37:24:009096 gpinitsystem:mdw:gpadmin-[INFO]:------------------------------------------------
20180815:15:37:24:009096 gpinitsystem:mdw:gpadmin-[INFO]:-Total processes marked as completed           = 1
20180815:15:37:24:009096 gpinitsystem:mdw:gpadmin-[INFO]:-Total processes marked as killed              = 0
20180815:15:37:24:009096 gpinitsystem:mdw:gpadmin-[INFO]:-Total processes marked as failed              = 0
20180815:15:37:24:009096 gpinitsystem:mdw:gpadmin-[INFO]:------------------------------------------------
20180815:15:37:24:009096 gpinitsystem:mdw:gpadmin-[INFO]:-Deleting distributed backout files
20180815:15:37:24:009096 gpinitsystem:mdw:gpadmin-[INFO]:-Removing back out file
20180815:15:37:24:009096 gpinitsystem:mdw:gpadmin-[INFO]:-No errors generated from parallel processes
20180815:15:37:24:009096 gpinitsystem:mdw:gpadmin-[INFO]:-Restarting the Greenplum instance in production mode
20180815:15:37:24:010798 gpstop:mdw:gpadmin-[INFO]:-Starting gpstop with args: -a -l /home/gpadmin/gpAdminLogs -i -m -d /data/greenplum/master/gpseg-1
20180815:15:37:24:010798 gpstop:mdw:gpadmin-[INFO]:-Gathering information and validating the environment...
20180815:15:37:24:010798 gpstop:mdw:gpadmin-[INFO]:-Obtaining Greenplum Master catalog information
20180815:15:37:24:010798 gpstop:mdw:gpadmin-[INFO]:-Obtaining Segment details from master...
20180815:15:37:24:010798 gpstop:mdw:gpadmin-[INFO]:-Greenplum Version: 'postgres (Greenplum Database) 4.3.25.1 build 1'
20180815:15:37:24:010798 gpstop:mdw:gpadmin-[INFO]:-There are 0 connections to the database
20180815:15:37:24:010798 gpstop:mdw:gpadmin-[INFO]:-Commencing Master instance shutdown with mode='immediate'
20180815:15:37:24:010798 gpstop:mdw:gpadmin-[INFO]:-Master host=mdw
20180815:15:37:24:010798 gpstop:mdw:gpadmin-[INFO]:-Commencing Master instance shutdown with mode=immediate
20180815:15:37:24:010798 gpstop:mdw:gpadmin-[INFO]:-Master segment instance directory=/data/greenplum/master/gpseg-1
20180815:15:37:25:010798 gpstop:mdw:gpadmin-[INFO]:-Attempting forceful termination of any leftover master process
20180815:15:37:25:010798 gpstop:mdw:gpadmin-[INFO]:-Terminating processes for segment /data/greenplum/master/gpseg-1
20180815:15:37:25:010822 gpstart:mdw:gpadmin-[INFO]:-Starting gpstart with args: -a -l /home/gpadmin/gpAdminLogs -d /data/greenplum/master/gpseg-1
20180815:15:37:25:010822 gpstart:mdw:gpadmin-[INFO]:-Gathering information and validating the environment...
20180815:15:37:25:010822 gpstart:mdw:gpadmin-[INFO]:-Greenplum Binary Version: 'postgres (Greenplum Database) 4.3.25.1 build 1'
20180815:15:37:25:010822 gpstart:mdw:gpadmin-[INFO]:-Greenplum Catalog Version: '201310150'
20180815:15:37:25:010822 gpstart:mdw:gpadmin-[INFO]:-Starting Master instance in admin mode
20180815:15:37:27:010822 gpstart:mdw:gpadmin-[INFO]:-Obtaining Greenplum Master catalog information
20180815:15:37:27:010822 gpstart:mdw:gpadmin-[INFO]:-Obtaining Segment details from master...
20180815:15:37:27:010822 gpstart:mdw:gpadmin-[INFO]:-Setting new master era
20180815:15:37:27:010822 gpstart:mdw:gpadmin-[INFO]:-Master Started...
20180815:15:37:27:010822 gpstart:mdw:gpadmin-[INFO]:-Shutting down master
20180815:15:37:28:010822 gpstart:mdw:gpadmin-[INFO]:-Commencing parallel segment instance startup, please wait...
........ 
20180815:15:37:36:010822 gpstart:mdw:gpadmin-[INFO]:-Process results...
20180815:15:37:36:010822 gpstart:mdw:gpadmin-[INFO]:-----------------------------------------------------
20180815:15:37:36:010822 gpstart:mdw:gpadmin-[INFO]:-   Successful segment starts                                            = 1
20180815:15:37:36:010822 gpstart:mdw:gpadmin-[INFO]:-   Failed segment starts                                                = 0
20180815:15:37:36:010822 gpstart:mdw:gpadmin-[INFO]:-   Skipped segment starts (segments are marked down in configuration)   = 0
20180815:15:37:36:010822 gpstart:mdw:gpadmin-[INFO]:-----------------------------------------------------
20180815:15:37:36:010822 gpstart:mdw:gpadmin-[INFO]:-
20180815:15:37:36:010822 gpstart:mdw:gpadmin-[INFO]:-Successfully started 1 of 1 segment instances 
20180815:15:37:36:010822 gpstart:mdw:gpadmin-[INFO]:-----------------------------------------------------
20180815:15:37:36:010822 gpstart:mdw:gpadmin-[INFO]:-Starting Master instance mdw directory /data/greenplum/master/gpseg-1 
20180815:15:37:37:010822 gpstart:mdw:gpadmin-[INFO]:-Command pg_ctl reports Master mdw instance active
20180815:15:37:37:010822 gpstart:mdw:gpadmin-[INFO]:-No standby master configured.  skipping...
20180815:15:37:37:010822 gpstart:mdw:gpadmin-[INFO]:-Database successfully started
20180815:15:37:40:009096 gpinitsystem:mdw:gpadmin-[INFO]:-Completed restart of Greenplum instance in production mode
20180815:15:37:40:009096 gpinitsystem:mdw:gpadmin-[INFO]:-Loading gp_toolkit...
20180815:15:37:43:009096 gpinitsystem:mdw:gpadmin-[INFO]:-Scanning utility log file for any warning messages
20180815:15:37:43:009096 gpinitsystem:mdw:gpadmin-[WARN]:-*******************************************************
20180815:15:37:43:009096 gpinitsystem:mdw:gpadmin-[WARN]:-Scan of log file indicates that some warnings or errors
20180815:15:37:43:009096 gpinitsystem:mdw:gpadmin-[WARN]:-were generated during the array creation
20180815:15:37:43:009096 gpinitsystem:mdw:gpadmin-[INFO]:-Please review contents of log file
20180815:15:37:43:009096 gpinitsystem:mdw:gpadmin-[INFO]:-/home/gpadmin/gpAdminLogs/gpinitsystem_20180815.log
20180815:15:37:43:009096 gpinitsystem:mdw:gpadmin-[INFO]:-To determine level of criticality
20180815:15:37:43:009096 gpinitsystem:mdw:gpadmin-[INFO]:-These messages could be from a previous run of the utility
20180815:15:37:43:009096 gpinitsystem:mdw:gpadmin-[INFO]:-that was called today!
20180815:15:37:43:009096 gpinitsystem:mdw:gpadmin-[WARN]:-*******************************************************
20180815:15:37:43:009096 gpinitsystem:mdw:gpadmin-[INFO]:-Greenplum Database instance successfully created
20180815:15:37:43:009096 gpinitsystem:mdw:gpadmin-[INFO]:-------------------------------------------------------
20180815:15:37:43:009096 gpinitsystem:mdw:gpadmin-[INFO]:-To complete the environment configuration, please 
20180815:15:37:43:009096 gpinitsystem:mdw:gpadmin-[INFO]:-update gpadmin .bashrc file with the following
20180815:15:37:43:009096 gpinitsystem:mdw:gpadmin-[INFO]:-1. Ensure that the greenplum_path.sh file is sourced
20180815:15:37:43:009096 gpinitsystem:mdw:gpadmin-[INFO]:-2. Add "export MASTER_DATA_DIRECTORY=/data/greenplum/master/gpseg-1"
20180815:15:37:43:009096 gpinitsystem:mdw:gpadmin-[INFO]:-   to access the Greenplum scripts for this instance:
20180815:15:37:43:009096 gpinitsystem:mdw:gpadmin-[INFO]:-   or, use -d /data/greenplum/master/gpseg-1 option for the Greenplum scripts
20180815:15:37:43:009096 gpinitsystem:mdw:gpadmin-[INFO]:-   Example gpstate -d /data/greenplum/master/gpseg-1
20180815:15:37:43:009096 gpinitsystem:mdw:gpadmin-[INFO]:-Script log file = /home/gpadmin/gpAdminLogs/gpinitsystem_20180815.log
20180815:15:37:43:009096 gpinitsystem:mdw:gpadmin-[INFO]:-To remove instance, run gpdeletesystem utility
20180815:15:37:43:009096 gpinitsystem:mdw:gpadmin-[INFO]:-To initialize a Standby Master Segment for this Greenplum instance
20180815:15:37:43:009096 gpinitsystem:mdw:gpadmin-[INFO]:-Review options for gpinitstandby
20180815:15:37:43:009096 gpinitsystem:mdw:gpadmin-[INFO]:-------------------------------------------------------
20180815:15:37:43:009096 gpinitsystem:mdw:gpadmin-[INFO]:-The Master /data/greenplum/master/gpseg-1/pg_hba.conf post gpinitsystem
20180815:15:37:43:009096 gpinitsystem:mdw:gpadmin-[INFO]:-has been configured to allow all hosts within this new
20180815:15:37:43:009096 gpinitsystem:mdw:gpadmin-[INFO]:-array to intercommunicate. Any hosts external to this
20180815:15:37:43:009096 gpinitsystem:mdw:gpadmin-[INFO]:-new array must be explicitly added to this file
20180815:15:37:43:009096 gpinitsystem:mdw:gpadmin-[INFO]:-Refer to the Greenplum Admin support guide which is
20180815:15:37:43:009096 gpinitsystem:mdw:gpadmin-[INFO]:-located in the /usr/local/greenplum-db/./docs directory
20180815:15:37:43:009096 gpinitsystem:mdw:gpadmin-[INFO]:-------------------------------------------------------
```