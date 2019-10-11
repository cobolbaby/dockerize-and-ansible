
# Ref:https://gpdb.docs.pivotal.io/5150/install_guide/init_gpdb.html#topic8
source /usr/local/greenplum-db/greenplum_path.sh
export MASTER_DATA_DIRECTORY=/disk1/gpdata/gpmaster/gpseg-1
# (Optional) You may also want to set some client session environment variables 
# such as PGPORT, PGUSER and PGDATABASE for convenience.
export PGPORT=5432
# (Optional) If you use RHEL 7 or CentOS 7, add the following line to the end of the .bashrc file
# to enable using the ps command in the greenplum_path.sh environment
export LD_PRELOAD=/lib64/libz.so.1 ps
# Support PXF
export JAVA_HOME=/usr/lib/jvm/java-1.8.0-openjdk-1.8.0.222.b10-1.el7_7.x86_64/jre
