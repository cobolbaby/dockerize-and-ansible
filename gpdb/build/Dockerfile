FROM centos:7

# Argument
ARG GPDB_VERSION_FULL="4.3.25.1-rhel5-x86_64"
ARG WORK_DIR=/opt/greenplum
ARG TMP_DIR=/tmp/greenplum
ARG MASTER_DATA_PATH=/data/greenplum/master
ARG PRIMARY_DATA_PATH=/data/greenplum/primary
ARG MIRROR_DATA_PATH=/data/greenplum/mirror

RUN mkdir -p $WORK_DIR/config
WORKDIR $WORK_DIR

COPY pkgs/* $TMP_DIR/
COPY etc/* $TMP_DIR/
COPY entrypoint.sh .

RUN cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo 'Asia/Shanghai' > /etc/timezone \
    && mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup \
    && curl -so /etc/yum.repos.d/CentOS-Base.repo http://mirrors.163.com/.help/CentOS7-Base-163.repo \
    && yum install -y net-tools which scp openssh-clients openssh-server less iproute sudo telnet telnet-server \
    && yum clean all \
    && echo root:inventec | chpasswd \
    && groupadd gpadmin \
    && useradd -g gpadmin -m -d /home/gpadmin -s /bin/bash gpadmin \
    && echo gpadmin:gpadmin | chpasswd \
    && chown -R gpadmin:gpadmin $WORK_DIR \
    && sed -i s/"more << EOF"/"cat << EOF"/g ${TMP_DIR}/greenplum-db-${GPDB_VERSION_FULL}.bin \
    && echo -e "yes\n\nyes\nyes\n" | ${TMP_DIR}/greenplum-db-${GPDB_VERSION_FULL}.bin \
    && chown -R gpadmin:gpadmin /usr/local/greenplum-db* \
    && mkdir -p $MASTER_DATA_PATH $PRIMARY_DATA_PATH $MIRROR_DATA_PATH \
    && chown -R gpadmin:gpadmin $MASTER_DATA_PATH $PRIMARY_DATA_PATH $MIRROR_DATA_PATH \
    && ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key \
    && ssh-keygen -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key \
    && ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key \
    && echo 'gpadmin ALL=(ALL) NOPASSWD:/usr/sbin/sshd' >> /etc/sudoers \
    && mkdir -p /home/gpadmin/.ssh  \
    && ssh-keygen -t rsa -f /home/gpadmin/.ssh/id_rsa \
    && cat /home/gpadmin/.ssh/id_rsa.pub >> /home/gpadmin/.ssh/authorized_keys \
    && chown -R gpadmin:gpadmin /home/gpadmin/.ssh \
    && chmod 700 /home/gpadmin/.ssh \
    && chmod 600 /home/gpadmin/.ssh/authorized_keys \
    && cat ${TMP_DIR}/etc_sysctl.conf >> /etc/sysctl.conf \
    && cat ${TMP_DIR}/etc_security_limits.conf >> /etc/security/limits.conf \
    && cat ${TMP_DIR}/etc_selinux_config >> /etc/selinux/config \
    && rm -rf ${TMP_DIR} \
    && chmod +x entrypoint.sh
    
USER gpadmin

ENV LANG en_US.UTF-8
# fix: No such file or directory: '/data/greenplum/master/postgresql.conf
ENV MASTER_DATA_DIRECTORY $MASTER_DATA_PATH/gpseg-1
ENV PGPORT 5432
# fix: 通过`source /usr/local/greenplum-db/greenplum_path.sh`无法使环境变量生效
ENV GPHOME /usr/local/greenplum-db
ENV PYTHONHOME $GPHOME/ext/python
ENV PYTHONPATH $GPHOME/lib/python
ENV PATH $GPHOME/bin:$PYTHONHOME/bin:$PATH
ENV LD_LIBRARY_PATH $GPHOME/lib:$PYTHONHOME/lib:$LD_LIBRARY_PATH
ENV OPENSSL_CONF $GPHOME/etc/openssl.cnf
# fix: Environment Variable LOGNAME or USER not set
ENV USER gpadmin

# 声明镜像内服务所监听的端口，但是此处只是声明，并不会自动完成端口映射
EXPOSE 5432 22

ENTRYPOINT [ "./entrypoint.sh" ]