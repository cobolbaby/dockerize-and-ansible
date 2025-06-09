# 坑

## Build

### v9.5 BUILD FAILURE

```bash
[INFO] ------------------------------------------------------------------------
[INFO] BUILD FAILURE
[INFO] ------------------------------------------------------------------------
[INFO] Total time:  01:35 min
[INFO] Finished at: 2025-06-09T04:55:13Z
[INFO] ------------------------------------------------------------------------
[ERROR] Failed to execute goal on project kettle-core: Could not resolve dependencies for project pentaho-kettle:kettle-core:jar:9.5.0.0-SNAPSHOT
[ERROR] dependency: org.pentaho:pentaho-encryption-support:jar:9.5.0.0-SNAPSHOT (compile)
[ERROR] 	Could not find artifact org.pentaho:pentaho-encryption-support:jar:9.5.0.0-SNAPSHOT in pentaho-public (https://repo.orl.eng.hitachivantara.com/artifactory/pnt-mvn/)
[ERROR] 
[ERROR] -> [Help 1]
[ERROR] 
[ERROR] To see the full stack trace of the errors, re-run Maven with the -e switch.
[ERROR] Re-run Maven using the -X switch to enable full debug logging.
[ERROR] 
[ERROR] For more information about the errors and possible solutions, please read the following articles:
[ERROR] [Help 1] http://cwiki.apache.org/confluence/display/MAVEN/DependencyResolutionException
[ERROR] 
[ERROR] After correcting the problems, you can resume the build with the command
[ERROR]   mvn <args> -rf :kettle-core
The command '/bin/sh -c git clone --depth 1 --branch ${KETTLE_BRANCH} https://github.com/pentaho/pentaho-kettle.git &&     cd pentaho-kettle &&     mvn clean package -DskipTests' returned a non-zero code: 1
```

### v9.4 BUILD FAILURE

依赖包还是下载不全，个别包没有上推到公共仓库
