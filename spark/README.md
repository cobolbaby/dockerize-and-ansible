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

- spark使用swarm启动以后监控面板无法显示记录

```

```