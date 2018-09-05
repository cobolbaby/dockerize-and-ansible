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

- `Initial job has not accepted any resources`

```
2018-09-04 17:07:27 WARN  TaskSchedulerImpl:66 - Initial job has not accepted any resources; check your cluster UI to ensure that workers are registered and have sufficient resources
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

```
```

- `docker the input device is not a TTY`

```
去掉docker exec命令后面的-ti即可
```