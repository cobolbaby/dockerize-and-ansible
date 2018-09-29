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

    去掉docker exec命令后面的-ti即可

- `CoarseGrainedExecutorBackend`

```
18/09/29 13:29:37 WARN Utils: Service 'SparkUI' could not bind on port 4040. Attempting port 4041.
18/09/29 13:29:37 WARN Utils: Service 'SparkUI' could not bind on port 4041. Attempting port 4042.
18/09/29 13:29:37 WARN Utils: Service 'SparkUI' could not bind on port 4042. Attempting port 4043.
18/09/29 13:29:37 WARN Utils: Service 'SparkUI' could not bind on port 4043. Attempting port 4044.
18/09/29 13:29:37 WARN Utils: Service 'SparkUI' could not bind on port 4044. Attempting port 4045.
18/09/29 13:29:37 WARN NativeCodeLoader: Unable to load native-hadoop library for your platform... using builtin-java classes where applicable
18/09/29 13:29:37 WARN NativeCodeLoader: Unable to load native-hadoop library for your platform... using builtin-java classes where applicable
18/09/29 13:29:43 ERROR CoarseGrainedExecutorBackend: RECEIVED SIGNAL TERM
```

- `[Greenplum]sorry, too many clients already`

```
18/09/29 13:46:39 ERROR Executor: Exception in task 49.0 in stage 733.0 (TID 889)
java.sql.SQLException: [Pivotal][Greenplum JDBC Driver][Greenplum]sorry, too many clients already. 
	at com.pivotal.jdbc.greenplumbase.ddcd.b(Unknown Source)
	at com.pivotal.jdbc.greenplumbase.ddcd.a(Unknown Source)
	at com.pivotal.jdbc.greenplumbase.ddcc.b(Unknown Source)
	at com.pivotal.jdbc.greenplumbase.ddcc.a(Unknown Source)
	at com.pivotal.jdbc.greenplum.wp.dde.l(Unknown Source)
	at com.pivotal.jdbc.greenplum.wp.dde.i(Unknown Source)
	at com.pivotal.jdbc.greenplum.GreenplumImplConnection.a4(Unknown Source)
	at com.pivotal.jdbc.greenplum.GreenplumImplConnection.c(Unknown Source)
	at com.pivotal.jdbc.greenplumbase.BaseConnection.b(Unknown Source)
	at com.pivotal.jdbc.greenplumbase.BaseConnection.k(Unknown Source)
	at com.pivotal.jdbc.greenplumbase.BaseConnection.b(Unknown Source)
	at com.pivotal.jdbc.greenplumbase.BaseConnection.a(Unknown Source)
	at com.pivotal.jdbc.greenplumbase.BaseDriver.connect(Unknown Source)
	at org.apache.spark.sql.execution.datasources.jdbc.JdbcUtils$$anonfun$createConnectionFactory$1.apply(JdbcUtils.scala:63)
	at org.apache.spark.sql.execution.datasources.jdbc.JdbcUtils$$anonfun$createConnectionFactory$1.apply(JdbcUtils.scala:54)
	at org.apache.spark.sql.execution.datasources.jdbc.JdbcUtils$.savePartition(JdbcUtils.scala:600)
	at org.apache.spark.sql.execution.datasources.jdbc.JdbcUtils$$anonfun$saveTable$1.apply(JdbcUtils.scala:821)
	at org.apache.spark.sql.execution.datasources.jdbc.JdbcUtils$$anonfun$saveTable$1.apply(JdbcUtils.scala:821)
	at org.apache.spark.rdd.RDD$$anonfun$foreachPartition$1$$anonfun$apply$29.apply(RDD.scala:929)
	at org.apache.spark.rdd.RDD$$anonfun$foreachPartition$1$$anonfun$apply$29.apply(RDD.scala:929)
	at org.apache.spark.SparkContext$$anonfun$runJob$5.apply(SparkContext.scala:2067)
	at org.apache.spark.SparkContext$$anonfun$runJob$5.apply(SparkContext.scala:2067)
	at org.apache.spark.scheduler.ResultTask.runTask(ResultTask.scala:87)
	at org.apache.spark.scheduler.Task.run(Task.scala:109)
	at org.apache.spark.executor.Executor$TaskRunner.run(Executor.scala:345)
	at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1149)
	at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:624)
	at java.lang.Thread.run(Thread.java:748)
```

- 如何配置默认
