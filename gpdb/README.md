- `which` command not found
```
********************************************************************************
Error: sed was not found in your path.
       sed is needed to run this installer.
       Please add sed to your path before running the installer again.
       Exiting installer.
********************************************************************************
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
- `ssh_host_rsa_key` not exists
```
[root@mdw greenplum]# /usr/sbin/sshd
Could not load host key: /etc/ssh/ssh_host_rsa_key
Could not load host key: /etc/ssh/ssh_host_ecdsa_key
Could not load host key: /etc/ssh/ssh_host_ed25519_key
sshd: no hostkeys available -- exiting.
```
- `sshd` 服务没起
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

- `MASTER_DATA_DIRECTORY` 环境变量配置问题

```
[gpadmin@mdw opt]$ gpstop -u
20180815:17:20:16:013888 gpstop:mdw:gpadmin-[INFO]:-Starting gpstop with args: -u
20180815:17:20:16:013888 gpstop:mdw:gpadmin-[INFO]:-Gathering information and validating the environment...
20180815:17:20:16:013888 gpstop:mdw:gpadmin-[CRITICAL]:-gpstop failed. (Reason='[Errno 2] No such file or directory: '/data/greenplum/master/postgresql.conf'') exiting...
```

- `host` 模式组网的问题

一个节点只能起一个容器，因为容器都需要暴露22端口，如果在一个节点上起多个容器的话，会造成宿主机端口冲突

- `Docker Swarm Service Connection Refused`

```
20180823:15:58:49:002445 gpcreateseg.sh:mdw:gpadmin-[INFO]:-Commencing remote /bin/ssh sdw1 export GPHOME=/usr/local/greenplum-db; . /usr/local/greenplum-db/greenplum_path.sh; /usr/local/greenplum-db/bin/lib/pysync.py -x pg_log -x postgresql.conf -x postmaster.pid /data/greenplum/primary/gpseg0 \[sdw2\]:/data/greenplum/mirror/gpseg0
20180823:15:58:49:002458 gpcreateseg.sh:mdw:gpadmin-[INFO]:-Commencing remote /bin/ssh sdw2 export GPHOME=/usr/local/greenplum-db; . /usr/local/greenplum-db/greenplum_path.sh; /usr/local/greenplum-db/bin/lib/pysync.py -x pg_log -x postgresql.conf -x postmaster.pid /data/greenplum/primary/gpseg1 \[sdw1\]:/data/greenplum/mirror/gpseg1
Killed by signal 1.^M
Traceback (most recent call last):
  File "/usr/local/greenplum-db/bin/lib/pysync.py", line 669, in <module>
    sys.exit(LocalPysync(sys.argv, progressTimestamp=True).run())
  File "/usr/local/greenplum-db/bin/lib/pysync.py", line 647, in run
    code = self.work()
  File "/usr/local/greenplum-db/bin/lib/pysync.py", line 611, in work
    self.socket.connect(self.connectAddress)
  File "<string>", line 1, in connect
socket.error: [Errno 111] Connection refused
Killed by signal 1.^M
Traceback (most recent call last):
  File "/usr/local/greenplum-db/bin/lib/pysync.py", line 669, in <module>
    sys.exit(LocalPysync(sys.argv, progressTimestamp=True).run())
  File "/usr/local/greenplum-db/bin/lib/pysync.py", line 647, in run
    code = self.work()
  File "/usr/local/greenplum-db/bin/lib/pysync.py", line 611, in work
    self.socket.connect(self.connectAddress)
  File "<string>", line 1, in connect
socket.error: [Errno 111] Connection refused
20180823:15:58:52:002445 gpcreateseg.sh:mdw:gpadmin-[FATAL]:- Command export GPHOME=/usr/local/greenplum-db; . /usr/local/greenplum-db/greenplum_path.sh; /usr/local/greenplum-db/bin/lib/pysync.py -x pg_log -x postgresql.conf -x postmaster.pid /data/greenplum/primary/gpseg0 \[sdw2\]:/data/greenplum/mirror/gpseg0 on sdw1 failed with error status 1
20180823:15:58:52:002445 gpcreateseg.sh:mdw:gpadmin-[INFO]:-End Function RUN_COMMAND_REMOTE
20180823:15:58:52:002445 gpcreateseg.sh:mdw:gpadmin-[FATAL][0]:-Failed remote copy of segment data directory from sdw1 to sdw2
20180823:15:58:52:002458 gpcreateseg.sh:mdw:gpadmin-[FATAL]:- Command export GPHOME=/usr/local/greenplum-db; . /usr/local/greenplum-db/greenplum_path.sh; /usr/local/greenplum-db/bin/lib/pysync.py -x pg_log -x postgresql.conf -x postmaster.pid /data/greenplum/primary/gpseg1 \[sdw1\]:/data/greenplum/mirror/gpseg1 on sdw2 failed with error status 1
20180823:15:58:52:002458 gpcreateseg.sh:mdw:gpadmin-[INFO]:-End Function RUN_COMMAND_REMOTE
20180823:15:58:52:002458 gpcreateseg.sh:mdw:gpadmin-[FATAL][1]:-Failed remote copy of segment data directory from sdw2 to sdw1
```

- `--cluster-store and --cluster-advertise daemon configurations`

```
bigdatauser@CP70-bigdata-005:~$ docker swarm init --advertise-addr 10.99.170.58
Error response from daemon: --cluster-store and --cluster-advertise daemon configurations are incompatible with swarm mode
```

- `Data Permission denied`

```
[CRITICAL]:-gpstart failed. (Reason='[Errno 13] Permission denied: '/disk1/gpdata/gpmaster/gpseg-1/postgresql.conf'')
```

- `Swarm Service Name not known`

```
[gpadmin@mdw greenplum]$ ping sdw1
ping: sdw1: Name or service not known
[gpadmin@mdw greenplum]$ ping sdw2
ping: sdw2: Name or service not known
```

- `gpstart error: Catalog Versions are incompatible`


- `Command perl not found`

```
[gpadmin@mdw gpAdminLogs]$ gpconfig -c max_connections -v 2000 -m 500 --debug
  stdout='20180930:11:01:42:023730 gpaddconfig.py:default-[CRITICAL]:-Command perl not found
'
  stderr='Traceback (most recent call last):
  File "/usr/local/greenplum-db/sbin/gpaddconfig.py", line 88, in <module>
    cmd=InlinePerlReplace(name, fromString, toString, f)
  File "/usr/local/greenplum-db/lib/python/gppylib/commands/unix.py", line 534, in __init__
    cmdStr="%s -pi.bak -e's/%s/%s/g' %s" % (findCmdInPath('perl'), fromStr, toStr, file)
  File "/usr/local/greenplum-db/lib/python/gppylib/commands/unix.py", line 80, in findCmdInPath
    raise CommandNotFoundException(cmd,search_path)
gppylib.commands.unix.CommandNotFoundException: Could not locate command: 'perl' in this set of paths: ['/usr/kerberos/bin', '/usr/sfw/bin', '/opt/sfw/bin', '/bin', '/usr/local/bin', '/usr/bin', '/sbin', '/usr/sbin', '/usr/ucb', '/sw/bin', '/opt/Navisphere/bin', '/usr/local/greenplum-db/.']
'
```

- 恢复宕掉的数据节点

```
[gpadmin@mdw tmp]$ gprecoverseg -o ./recov
20180929:15:13:31:052921 gprecoverseg:mdw:gpadmin-[INFO]:-Starting gprecoverseg with args: -o recov
20180929:15:13:31:052921 gprecoverseg:mdw:gpadmin-[INFO]:-local Greenplum Version: 'postgres (Greenplum Database) 4.3.25.1 build 1'
20180929:15:13:31:052921 gprecoverseg:mdw:gpadmin-[INFO]:-master Greenplum Version: 'PostgreSQL 8.2.15 (Greenplum Database 4.3.25.1 build 1) on x86_64-unknown-linux-gnu, compiled by GCC gcc (GCC) 4.4.2 compiled on May 11 2018 00:42:53'
20180929:15:13:31:052921 gprecoverseg:mdw:gpadmin-[INFO]:-Checking if segments are ready to connect
20180929:15:13:31:052921 gprecoverseg:mdw:gpadmin-[INFO]:-Obtaining Segment details from master...
20180929:15:13:32:052921 gprecoverseg:mdw:gpadmin-[INFO]:-Obtaining Segment details from master...
20180929:15:13:34:052921 gprecoverseg:mdw:gpadmin-[INFO]:-Configuration file output to recov successfully.
[gpadmin@mdw tmp]$ ll
total 8
-rwx------ 1 root    root    836 Aug  5 06:05 ks-script-Lu6hIQ
-rw-rw-r-- 1 gpadmin gpadmin 464 Sep 29 15:13 recov
-rw------- 1 root    root      0 Aug  5 06:04 yum.log
[gpadmin@mdw tmp]$ more recov 
filespaceOrder=
sdw1:40000:/disk1/gpdata/gpsegment/primary/gpseg0
sdw1:40001:/disk2/gpdata/gpsegment/primary/gpseg1
sdw1:40002:/disk3/gpdata/gpsegment/primary/gpseg2
sdw3:50000:/disk1/gpdata/gpsegment/mirror/gpseg3
sdw2:40001:/disk2/gpdata/gpsegment/primary/gpseg4
sdw3:50002:/disk3/gpdata/gpsegment/mirror/gpseg5
sdw1:50000:/disk1/gpdata/gpsegment/mirror/gpseg12
sdw1:50001:/disk2/gpdata/gpsegment/mirror/gpseg13
sdw1:50002:/disk3/gpdata/gpsegment/mirror/gpseg14
[gpadmin@mdw tmp]$ cat recov  | wc -l
10
[gpadmin@mdw tmp]$  gprecoverseg -i ./recov
20180929:15:15:00:053080 gprecoverseg:mdw:gpadmin-[INFO]:-Starting gprecoverseg with args: -i ./recov
20180929:15:15:01:053080 gprecoverseg:mdw:gpadmin-[INFO]:-local Greenplum Version: 'postgres (Greenplum Database) 4.3.25.1 build 1'
20180929:15:15:01:053080 gprecoverseg:mdw:gpadmin-[INFO]:-master Greenplum Version: 'PostgreSQL 8.2.15 (Greenplum Database 4.3.25.1 build 1) on x86_64-unknown-linux-gnu, compiled by GCC gcc (GCC) 4.4.2 compiled on May 11 2018 00:42:53'
20180929:15:15:01:053080 gprecoverseg:mdw:gpadmin-[INFO]:-Checking if segments are ready to connect
20180929:15:15:01:053080 gprecoverseg:mdw:gpadmin-[INFO]:-Obtaining Segment details from master...
20180929:15:15:01:053080 gprecoverseg:mdw:gpadmin-[INFO]:-Obtaining Segment details from master...
20180929:15:15:03:053080 gprecoverseg:mdw:gpadmin-[INFO]:-Greenplum instance recovery parameters
20180929:15:15:03:053080 gprecoverseg:mdw:gpadmin-[INFO]:----------------------------------------------------------
20180929:15:15:03:053080 gprecoverseg:mdw:gpadmin-[INFO]:-Recovery from configuration -i option supplied
20180929:15:15:03:053080 gprecoverseg:mdw:gpadmin-[INFO]:----------------------------------------------------------
20180929:15:15:03:053080 gprecoverseg:mdw:gpadmin-[INFO]:-Recovery 1 of 9
20180929:15:15:03:053080 gprecoverseg:mdw:gpadmin-[INFO]:----------------------------------------------------------
20180929:15:15:03:053080 gprecoverseg:mdw:gpadmin-[INFO]:-   Synchronization mode                        = Incremental
20180929:15:15:03:053080 gprecoverseg:mdw:gpadmin-[INFO]:-   Failed instance host                        = sdw1
20180929:15:15:03:053080 gprecoverseg:mdw:gpadmin-[INFO]:-   Failed instance address                     = sdw1
20180929:15:15:03:053080 gprecoverseg:mdw:gpadmin-[INFO]:-   Failed instance directory                   = /disk1/gpdata/gpsegment/primary/gpseg0
20180929:15:15:03:053080 gprecoverseg:mdw:gpadmin-[INFO]:-   Failed instance port                        = 40000
20180929:15:15:03:053080 gprecoverseg:mdw:gpadmin-[INFO]:-   Failed instance replication port            = 41000
20180929:15:15:03:053080 gprecoverseg:mdw:gpadmin-[INFO]:-   Recovery Source instance host               = sdw2
20180929:15:15:03:053080 gprecoverseg:mdw:gpadmin-[INFO]:-   Recovery Source instance address            = sdw2
20180929:15:15:03:053080 gprecoverseg:mdw:gpadmin-[INFO]:-   Recovery Source instance directory          = /disk1/gpdata/gpsegment/mirror/gpseg0
20180929:15:15:03:053080 gprecoverseg:mdw:gpadmin-[INFO]:-   Recovery Source instance port               = 50000
20180929:15:15:03:053080 gprecoverseg:mdw:gpadmin-[INFO]:-   Recovery Source instance replication port   = 51000
20180929:15:15:03:053080 gprecoverseg:mdw:gpadmin-[INFO]:-   Recovery Target                             = in-place
20180929:15:15:03:053080 gprecoverseg:mdw:gpadmin-[INFO]:----------------------------------------------------------
20180929:15:15:03:053080 gprecoverseg:mdw:gpadmin-[INFO]:-Recovery 2 of 9
20180929:15:15:03:053080 gprecoverseg:mdw:gpadmin-[INFO]:----------------------------------------------------------
20180929:15:15:03:053080 gprecoverseg:mdw:gpadmin-[INFO]:-   Synchronization mode                        = Incremental
20180929:15:15:03:053080 gprecoverseg:mdw:gpadmin-[INFO]:-   Failed instance host                        = sdw1
20180929:15:15:03:053080 gprecoverseg:mdw:gpadmin-[INFO]:-   Failed instance address                     = sdw1
20180929:15:15:03:053080 gprecoverseg:mdw:gpadmin-[INFO]:-   Failed instance directory                   = /disk2/gpdata/gpsegment/primary/gpseg1
20180929:15:15:03:053080 gprecoverseg:mdw:gpadmin-[INFO]:-   Failed instance port                        = 40001
20180929:15:15:03:053080 gprecoverseg:mdw:gpadmin-[INFO]:-   Failed instance replication port            = 41001
20180929:15:15:03:053080 gprecoverseg:mdw:gpadmin-[INFO]:-   Recovery Source instance host               = sdw2
20180929:15:15:03:053080 gprecoverseg:mdw:gpadmin-[INFO]:-   Recovery Source instance address            = sdw2
20180929:15:15:03:053080 gprecoverseg:mdw:gpadmin-[INFO]:-   Recovery Source instance directory          = /disk2/gpdata/gpsegment/mirror/gpseg1
20180929:15:15:03:053080 gprecoverseg:mdw:gpadmin-[INFO]:-   Recovery Source instance port               = 50001
20180929:15:15:03:053080 gprecoverseg:mdw:gpadmin-[INFO]:-   Recovery Source instance replication port   = 51001
20180929:15:15:03:053080 gprecoverseg:mdw:gpadmin-[INFO]:-   Recovery Target                             = in-place
20180929:15:15:03:053080 gprecoverseg:mdw:gpadmin-[INFO]:----------------------------------------------------------

Continue with segment recovery procedure Yy|Nn (default=N):
> Y
20180929:15:16:11:053080 gprecoverseg:mdw:gpadmin-[INFO]:-9 segment(s) to recover
20180929:15:16:11:053080 gprecoverseg:mdw:gpadmin-[INFO]:-Ensuring 9 failed segment(s) are stopped
 
20180929:15:16:15:053080 gprecoverseg:mdw:gpadmin-[INFO]:-Ensuring that shared memory is cleaned up for stopped segments
20180929:15:16:20:053080 gprecoverseg:mdw:gpadmin-[ERROR]:-Unable to clean up shared memory for segment: (ipcrm: invalid id (229377)
)
Traceback (most recent call last):
  File "/usr/local/greenplum-db/lib/python/gppylib/commands/base.py", line 235, in run
    self.cmd.run()
  File "/usr/local/greenplum-db/lib/python/gppylib/operations/__init__.py", line 53, in run
    self.ret = self.execute()
  File "/usr/local/greenplum-db/lib/python/gppylib/operations/utils.py", line 52, in execute
    raise ret
Exception: Unable to clean up shared memory for segment: (ipcrm: invalid id (229377)
)
20180929:15:16:21:053080 gprecoverseg:mdw:gpadmin-[ERROR]:-Unable to clean up shared memory for segment: (ipcrm: invalid id (131076)
)
Traceback (most recent call last):
  File "/usr/local/greenplum-db/lib/python/gppylib/commands/base.py", line 235, in run
    self.cmd.run()
  File "/usr/local/greenplum-db/lib/python/gppylib/operations/__init__.py", line 53, in run
    self.ret = self.execute()
  File "/usr/local/greenplum-db/lib/python/gppylib/operations/utils.py", line 52, in execute
    raise ret
Exception: Unable to clean up shared memory for segment: (ipcrm: invalid id (131076)
)
20180929:15:16:21:053080 gprecoverseg:mdw:gpadmin-[WARNING]:-Unable to clean up shared memory for stopped segments on host (sdw1)
20180929:15:16:21:053080 gprecoverseg:mdw:gpadmin-[WARNING]:-Unable to clean up shared memory for stopped segments on host (sdw3)
updating flat files
20180929:15:16:21:053080 gprecoverseg:mdw:gpadmin-[INFO]:-Updating configuration with new mirrors
20180929:15:16:21:053080 gprecoverseg:mdw:gpadmin-[INFO]:-Updating mirrors
...... 
20180929:15:16:27:053080 gprecoverseg:mdw:gpadmin-[INFO]:-Starting mirrors
20180929:15:16:27:053080 gprecoverseg:mdw:gpadmin-[INFO]:-era is 067a8655633ca921_180929144926
20180929:15:16:27:053080 gprecoverseg:mdw:gpadmin-[INFO]:-Commencing parallel primary and mirror segment instance startup, please wait...
.......... 
20180929:15:16:37:053080 gprecoverseg:mdw:gpadmin-[INFO]:-Process results...
20180929:15:16:37:053080 gprecoverseg:mdw:gpadmin-[INFO]:-Updating configuration to mark mirrors up
20180929:15:16:37:053080 gprecoverseg:mdw:gpadmin-[INFO]:-Updating primaries
20180929:15:16:37:053080 gprecoverseg:mdw:gpadmin-[INFO]:-Commencing parallel primary conversion of 9 segments, please wait...
....................................................... 
20180929:15:17:32:053080 gprecoverseg:mdw:gpadmin-[INFO]:-Process results...
20180929:15:17:32:053080 gprecoverseg:mdw:gpadmin-[INFO]:-Done updating primaries
20180929:15:17:33:053080 gprecoverseg:mdw:gpadmin-[INFO]:-******************************************************************
20180929:15:17:33:053080 gprecoverseg:mdw:gpadmin-[INFO]:-Updating segments for resynchronization is completed.
20180929:15:17:33:053080 gprecoverseg:mdw:gpadmin-[INFO]:-For segments updated successfully, resynchronization will continue in the background.
20180929:15:17:33:053080 gprecoverseg:mdw:gpadmin-[INFO]:-
20180929:15:17:33:053080 gprecoverseg:mdw:gpadmin-[INFO]:-Use  gpstate -s  to check the resynchronization progress.
20180929:15:17:33:053080 gprecoverseg:mdw:gpadmin-[INFO]:-******************************************************************
[gpadmin@mdw tmp]$ gpstate -b
20180929:15:17:52:056971 gpstate:mdw:gpadmin-[INFO]:-Starting gpstate with args: -b
20180929:15:17:52:056971 gpstate:mdw:gpadmin-[INFO]:-local Greenplum Version: 'postgres (Greenplum Database) 4.3.25.1 build 1'
20180929:15:17:52:056971 gpstate:mdw:gpadmin-[INFO]:-master Greenplum Version: 'PostgreSQL 8.2.15 (Greenplum Database 4.3.25.1 build 1) on x86_64-unknown-linux-gnu, compiled by GCC gcc (GCC) 4.4.2 compiled on May 11 2018 00:42:53'
20180929:15:17:52:056971 gpstate:mdw:gpadmin-[INFO]:-Obtaining Segment details from master...
20180929:15:17:52:056971 gpstate:mdw:gpadmin-[INFO]:-Gathering data from segments...
. 
20180929:15:17:53:056971 gpstate:mdw:gpadmin-[INFO]:-Greenplum instance status summary
20180929:15:17:53:056971 gpstate:mdw:gpadmin-[INFO]:-----------------------------------------------------
20180929:15:17:53:056971 gpstate:mdw:gpadmin-[INFO]:-   Master instance                                           = Active
20180929:15:17:53:056971 gpstate:mdw:gpadmin-[INFO]:-   Master standby                                            = sdw1
20180929:15:17:53:056971 gpstate:mdw:gpadmin-[INFO]:-   Standby master state                                      = Standby host passive
20180929:15:17:53:056971 gpstate:mdw:gpadmin-[INFO]:-   Total segment instance count from metadata                = 30
20180929:15:17:53:056971 gpstate:mdw:gpadmin-[INFO]:-----------------------------------------------------
20180929:15:17:53:056971 gpstate:mdw:gpadmin-[INFO]:-   Primary Segment Status
20180929:15:17:53:056971 gpstate:mdw:gpadmin-[INFO]:-----------------------------------------------------
20180929:15:17:53:056971 gpstate:mdw:gpadmin-[INFO]:-   Total primary segments                                    = 15
20180929:15:17:53:056971 gpstate:mdw:gpadmin-[INFO]:-   Total primary segment valid (at master)                   = 15
20180929:15:17:53:056971 gpstate:mdw:gpadmin-[INFO]:-   Total primary segment failures (at master)                = 0
20180929:15:17:53:056971 gpstate:mdw:gpadmin-[INFO]:-   Total number of postmaster.pid files missing              = 0
20180929:15:17:53:056971 gpstate:mdw:gpadmin-[INFO]:-   Total number of postmaster.pid files found                = 15
20180929:15:17:53:056971 gpstate:mdw:gpadmin-[INFO]:-   Total number of postmaster.pid PIDs missing               = 0
20180929:15:17:53:056971 gpstate:mdw:gpadmin-[INFO]:-   Total number of postmaster.pid PIDs found                 = 15
20180929:15:17:53:056971 gpstate:mdw:gpadmin-[INFO]:-   Total number of /tmp lock files missing                   = 0
20180929:15:17:53:056971 gpstate:mdw:gpadmin-[INFO]:-   Total number of /tmp lock files found                     = 15
20180929:15:17:53:056971 gpstate:mdw:gpadmin-[INFO]:-   Total number postmaster processes missing                 = 0
20180929:15:17:53:056971 gpstate:mdw:gpadmin-[INFO]:-   Total number postmaster processes found                   = 15
20180929:15:17:53:056971 gpstate:mdw:gpadmin-[INFO]:-----------------------------------------------------
20180929:15:17:53:056971 gpstate:mdw:gpadmin-[INFO]:-   Mirror Segment Status
20180929:15:17:53:056971 gpstate:mdw:gpadmin-[INFO]:-----------------------------------------------------
20180929:15:17:53:056971 gpstate:mdw:gpadmin-[INFO]:-   Total mirror segments                                     = 15
20180929:15:17:53:056971 gpstate:mdw:gpadmin-[INFO]:-   Total mirror segment valid (at master)                    = 15
20180929:15:17:53:056971 gpstate:mdw:gpadmin-[INFO]:-   Total mirror segment failures (at master)                 = 0
20180929:15:17:53:056971 gpstate:mdw:gpadmin-[INFO]:-   Total number of postmaster.pid files missing              = 0
20180929:15:17:53:056971 gpstate:mdw:gpadmin-[INFO]:-   Total number of postmaster.pid files found                = 15
20180929:15:17:53:056971 gpstate:mdw:gpadmin-[INFO]:-   Total number of postmaster.pid PIDs missing               = 0
20180929:15:17:53:056971 gpstate:mdw:gpadmin-[INFO]:-   Total number of postmaster.pid PIDs found                 = 15
20180929:15:17:53:056971 gpstate:mdw:gpadmin-[INFO]:-   Total number of /tmp lock files missing                   = 0
20180929:15:17:53:056971 gpstate:mdw:gpadmin-[INFO]:-   Total number of /tmp lock files found                     = 15
20180929:15:17:53:056971 gpstate:mdw:gpadmin-[INFO]:-   Total number postmaster processes missing                 = 0
20180929:15:17:53:056971 gpstate:mdw:gpadmin-[INFO]:-   Total number postmaster processes found                   = 15
20180929:15:17:53:056971 gpstate:mdw:gpadmin-[WARNING]:-Total number mirror segments acting as primary segments   = 4                      <<<<<<<<
20180929:15:17:53:056971 gpstate:mdw:gpadmin-[INFO]:-   Total number mirror segments acting as mirror segments    = 11
20180929:15:17:53:056971 gpstate:mdw:gpadmin-[INFO]:-----------------------------------------------------
[gpadmin@mdw tmp]$ gprecoverseg -r
20180929:15:28:28:041514 gprecoverseg:mdw:gpadmin-[INFO]:-Starting gprecoverseg with args: -r
20180929:15:28:28:041514 gprecoverseg:mdw:gpadmin-[INFO]:-local Greenplum Version: 'postgres (Greenplum Database) 4.3.25.1 build 1'
20180929:15:28:28:041514 gprecoverseg:mdw:gpadmin-[INFO]:-master Greenplum Version: 'PostgreSQL 8.2.15 (Greenplum Database 4.3.25.1 build 1) on x86_64-unknown-linux-gnu, compiled by GCC gcc (GCC) 4.4.2 compiled on May 11 2018 00:42:53'
20180929:15:28:28:041514 gprecoverseg:mdw:gpadmin-[INFO]:-Checking if segments are ready to connect
20180929:15:28:28:041514 gprecoverseg:mdw:gpadmin-[INFO]:-Obtaining Segment details from master...
20180929:15:28:29:041514 gprecoverseg:mdw:gpadmin-[INFO]:-Obtaining Segment details from master...
20180929:15:28:29:041514 gprecoverseg:mdw:gpadmin-[INFO]:-Greenplum instance recovery parameters
20180929:15:28:29:041514 gprecoverseg:mdw:gpadmin-[INFO]:----------------------------------------------------------
20180929:15:28:29:041514 gprecoverseg:mdw:gpadmin-[INFO]:-Recovery type              = Rebalance
20180929:15:28:29:041514 gprecoverseg:mdw:gpadmin-[INFO]:----------------------------------------------------------
20180929:15:28:29:041514 gprecoverseg:mdw:gpadmin-[INFO]:-Unbalanced segment 1 of 8
20180929:15:28:29:041514 gprecoverseg:mdw:gpadmin-[INFO]:----------------------------------------------------------
20180929:15:28:29:041514 gprecoverseg:mdw:gpadmin-[INFO]:-   Unbalanced instance host               = sdw2
20180929:15:28:29:041514 gprecoverseg:mdw:gpadmin-[INFO]:-   Unbalanced instance address            = sdw2
20180929:15:28:29:041514 gprecoverseg:mdw:gpadmin-[INFO]:-   Unbalanced instance directory          = /disk1/gpdata/gpsegment/mirror/gpseg0
20180929:15:28:29:041514 gprecoverseg:mdw:gpadmin-[INFO]:-   Unbalanced instance port               = 50000
20180929:15:28:29:041514 gprecoverseg:mdw:gpadmin-[INFO]:-   Unbalanced instance replication port   = 51000
20180929:15:28:29:041514 gprecoverseg:mdw:gpadmin-[INFO]:-   Balanced role                          = Mirror
20180929:15:28:29:041514 gprecoverseg:mdw:gpadmin-[INFO]:-   Current role                           = Primary
20180929:15:28:29:041514 gprecoverseg:mdw:gpadmin-[INFO]:----------------------------------------------------------
20180929:15:28:29:041514 gprecoverseg:mdw:gpadmin-[WARNING]:-This operation will cancel queries that are currently executing.
20180929:15:28:29:041514 gprecoverseg:mdw:gpadmin-[WARNING]:-Connections to the database however will not be interrupted.

Continue with segment rebalance procedure Yy|Nn (default=N):
> Y
20180929:15:28:33:041514 gprecoverseg:mdw:gpadmin-[INFO]:-Getting unbalanced segments
20180929:15:28:33:041514 gprecoverseg:mdw:gpadmin-[INFO]:-Stopping unbalanced primary segments...
........ 
20180929:15:28:41:041514 gprecoverseg:mdw:gpadmin-[INFO]:-Triggering segment reconfiguration
20180929:15:28:45:041514 gprecoverseg:mdw:gpadmin-[INFO]:-Starting segment synchronization
20180929:15:28:45:041514 gprecoverseg:mdw:gpadmin-[INFO]:-=============================START ANOTHER RECOVER=========================================
20180929:15:28:45:041514 gprecoverseg:mdw:gpadmin-[INFO]:-local Greenplum Version: 'postgres (Greenplum Database) 4.3.25.1 build 1'
20180929:15:28:45:041514 gprecoverseg:mdw:gpadmin-[INFO]:-master Greenplum Version: 'PostgreSQL 8.2.15 (Greenplum Database 4.3.25.1 build 1) on x86_64-unknown-linux-gnu, compiled by GCC gcc (GCC) 4.4.2 compiled on May 11 2018 00:42:53'
20180929:15:28:45:041514 gprecoverseg:mdw:gpadmin-[INFO]:-Checking if segments are ready to connect
20180929:15:28:45:041514 gprecoverseg:mdw:gpadmin-[INFO]:-Obtaining Segment details from master...
20180929:15:28:46:041514 gprecoverseg:mdw:gpadmin-[INFO]:-Obtaining Segment details from master...
20180929:15:28:48:041514 gprecoverseg:mdw:gpadmin-[INFO]:-Greenplum instance recovery parameters
20180929:15:28:48:041514 gprecoverseg:mdw:gpadmin-[INFO]:----------------------------------------------------------
20180929:15:28:48:041514 gprecoverseg:mdw:gpadmin-[INFO]:-Recovery type              = Standard
20180929:15:28:48:041514 gprecoverseg:mdw:gpadmin-[INFO]:----------------------------------------------------------
20180929:15:28:48:041514 gprecoverseg:mdw:gpadmin-[INFO]:-Recovery 1 of 4
20180929:15:28:48:041514 gprecoverseg:mdw:gpadmin-[INFO]:----------------------------------------------------------
20180929:15:28:48:041514 gprecoverseg:mdw:gpadmin-[INFO]:-   Synchronization mode                        = Incremental
20180929:15:28:48:041514 gprecoverseg:mdw:gpadmin-[INFO]:-   Failed instance host                        = sdw2
20180929:15:28:48:041514 gprecoverseg:mdw:gpadmin-[INFO]:-   Failed instance address                     = sdw2
20180929:15:28:48:041514 gprecoverseg:mdw:gpadmin-[INFO]:-   Failed instance directory                   = /disk1/gpdata/gpsegment/mirror/gpseg0
20180929:15:28:48:041514 gprecoverseg:mdw:gpadmin-[INFO]:-   Failed instance port                        = 50000
20180929:15:28:48:041514 gprecoverseg:mdw:gpadmin-[INFO]:-   Failed instance replication port            = 51000
20180929:15:28:48:041514 gprecoverseg:mdw:gpadmin-[INFO]:-   Recovery Source instance host               = sdw1
20180929:15:28:48:041514 gprecoverseg:mdw:gpadmin-[INFO]:-   Recovery Source instance address            = sdw1
20180929:15:28:48:041514 gprecoverseg:mdw:gpadmin-[INFO]:-   Recovery Source instance directory          = /disk1/gpdata/gpsegment/primary/gpseg0
20180929:15:28:48:041514 gprecoverseg:mdw:gpadmin-[INFO]:-   Recovery Source instance port               = 40000
20180929:15:28:48:041514 gprecoverseg:mdw:gpadmin-[INFO]:-   Recovery Source instance replication port   = 41000
20180929:15:28:48:041514 gprecoverseg:mdw:gpadmin-[INFO]:-   Recovery Target                             = in-place
20180929:15:28:48:041514 gprecoverseg:mdw:gpadmin-[INFO]:----------------------------------------------------------
20180929:15:28:48:041514 gprecoverseg:mdw:gpadmin-[INFO]:-4 segment(s) to recover
20180929:15:28:48:041514 gprecoverseg:mdw:gpadmin-[INFO]:-Ensuring 4 failed segment(s) are stopped
 
20180929:15:28:49:041514 gprecoverseg:mdw:gpadmin-[INFO]:-Ensuring that shared memory is cleaned up for stopped segments
updating flat files
20180929:15:28:55:041514 gprecoverseg:mdw:gpadmin-[INFO]:-Updating configuration with new mirrors
20180929:15:28:56:041514 gprecoverseg:mdw:gpadmin-[INFO]:-Updating mirrors
...... 
20180929:15:29:02:041514 gprecoverseg:mdw:gpadmin-[INFO]:-Starting mirrors
20180929:15:29:02:041514 gprecoverseg:mdw:gpadmin-[INFO]:-era is 067a8655633ca921_180929144926
20180929:15:29:02:041514 gprecoverseg:mdw:gpadmin-[INFO]:-Commencing parallel primary and mirror segment instance startup, please wait...
........ 
20180929:15:29:10:041514 gprecoverseg:mdw:gpadmin-[INFO]:-Process results...
20180929:15:29:10:041514 gprecoverseg:mdw:gpadmin-[INFO]:-Updating configuration to mark mirrors up
20180929:15:29:10:041514 gprecoverseg:mdw:gpadmin-[INFO]:-Updating primaries
20180929:15:29:10:041514 gprecoverseg:mdw:gpadmin-[INFO]:-Commencing parallel primary conversion of 4 segments, please wait...
...... 
20180929:15:29:16:041514 gprecoverseg:mdw:gpadmin-[INFO]:-Process results...
20180929:15:29:16:041514 gprecoverseg:mdw:gpadmin-[INFO]:-Done updating primaries
20180929:15:29:16:041514 gprecoverseg:mdw:gpadmin-[INFO]:-******************************************************************
20180929:15:29:16:041514 gprecoverseg:mdw:gpadmin-[INFO]:-Updating segments for resynchronization is completed.
20180929:15:29:16:041514 gprecoverseg:mdw:gpadmin-[INFO]:-For segments updated successfully, resynchronization will continue in the background.
20180929:15:29:16:041514 gprecoverseg:mdw:gpadmin-[INFO]:-
20180929:15:29:16:041514 gprecoverseg:mdw:gpadmin-[INFO]:-Use  gpstate -s  to check the resynchronization progress.
20180929:15:29:16:041514 gprecoverseg:mdw:gpadmin-[INFO]:-******************************************************************
20180929:15:29:20:041514 gprecoverseg:mdw:gpadmin-[INFO]:-==============================END ANOTHER RECOVER==========================================
20180929:15:29:25:041514 gprecoverseg:mdw:gpadmin-[INFO]:-******************************************************************
20180929:15:29:25:041514 gprecoverseg:mdw:gpadmin-[INFO]:-The rebalance operation has completed successfully.
20180929:15:29:25:041514 gprecoverseg:mdw:gpadmin-[INFO]:-There is a resynchronization running in the background to bring all
20180929:15:29:25:041514 gprecoverseg:mdw:gpadmin-[INFO]:-segments in sync.
20180929:15:29:25:041514 gprecoverseg:mdw:gpadmin-[INFO]:-
20180929:15:29:25:041514 gprecoverseg:mdw:gpadmin-[INFO]:-Use gpstate -e to check the resynchronization progress.
20180929:15:29:25:041514 gprecoverseg:mdw:gpadmin-[INFO]:-******************************************************************
```
