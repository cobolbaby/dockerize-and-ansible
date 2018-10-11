-  `JAVA_HOME is not set`

```
[root@sparkmaster spark-2.3.0-bin-hadoop2.7]# ./sbin/start-all.sh 
starting org.apache.spark.deploy.master.Master, logging to /opt/spark/logs/spark--org.apache.spark.deploy.master.Master-1-sparkmaster.out
sparkworker: Warning: Permanently added 'sparkworker,10.0.0.6' (ECDSA) to the list of known hosts.
sparkworker: starting org.apache.spark.deploy.worker.Worker, logging to /opt/spark/logs/spark-root-org.apache.spark.deploy.worker.Worker-1-sparkworker.out
sparkworker: failed to launch: nice -n 0 /opt/spark/bin/spark-class org.apache.spark.deploy.worker.Worker --webui-port 8081 spark://sparkmaster:7077
sparkworker:   JAVA_HOME is not set
sparkworker: full log in /opt/spark/logs/spark-root-org.apache.spark.deploy.worker.Worker-1-sparkworker.out
```

- `spark-submit command not found`

```
bigdatauser@CP70-bigdata-005:/opt/sparkv2$ docker exec -ti 5c8326d66d30 spark-submit --master spark://10.99.170.58:7077 /opt/tasks/python/pi.py
rpc error: code = 2 desc = oci runtime error: exec failed: container_linux.go:262: starting container process caused "exec: \"spark-submit\": executable file not found in $PATH"

bigdatauser@CP70-bigdata-005:~$ docker exec -ti 5c8326d66d30 /opt/spark/bin/spark-submit --master spark://10.99.170.58:7077 /opt/tasks/python/pi.py
18/09/05 03:13:40 WARN NativeCodeLoader: Unable to load native-hadoop library for your platform... using builtin-java classes where applicable
18/09/05 03:13:44 WARN TaskSetManager: Stage 0 contains a task of very large size (371 KB). The maximum recommended task size is 100 KB.
Pi is roughly 3.140840
```

- 使用`Swarm`启动以后`Executor`的监控面板无法显示

在编排文件中定义`SPARK_PUBLIC_DNS`以及`SPARK_WORKER_WEBUI_PORT`

- `docker the input device is not a TTY`

去掉`docker exec`命令后面的`-ti`即可

- `ERROR CoarseGrainedExecutorBackend: RECEIVED SIGNAL TERM`

内存的问题，增加`driver.memory`以后不再出现该问题

- `[Greenplum]sorry, too many clients already`

增大`max_connections`的值也可能会会出现该异常，此时请查看一下是否有`Down`的节点

- `PySpark fail with random "Socket is closed" error`

> https://blog.csdn.net/liyongqi_/article/details/52198795

- `Table "public"."spark_xxx"`

> https://greenplum-spark.docs.pivotal.io/140/install_cfg.html

- `[Greenplum]the limit of distributed transactions has been reached`

```
java.sql.SQLException: [Pivotal][Greenplum JDBC Driver][Greenplum]the limit of 512 distributed transactions has been reached. (cdbtm.c:2713). 
```

- `failed to create thread`

```
Master unable to connect to seg2 sdw1:40002 with options FATAL:  InitMotionLayerIPC: failed to create thread (ic_udpifc.c:1462)
```