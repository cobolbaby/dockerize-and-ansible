FROM centos:7

ENV LANG en_US.UTF-8
RUN cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo 'Asia/Shanghai' > /etc/timezone \
    && mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup \
    && curl -so /etc/yum.repos.d/CentOS-Base.repo http://mirrors.163.com/.help/CentOS7-Base-163.repo \
    && yum install -y net-tools which scp openssh-clients openssh-server less iproute \
    && yum clean all

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

RUN groupadd gpadmin \
    && useradd -g gpadmin -m -d /home/gpadmin -s /bin/bash gpadmin \
    && echo gpadmin:gpadmin | chpasswd \
    && chown -R gpadmin:gpadmin $WORK_DIR \
    && sed -i s/"more << EOF"/"cat << EOF"/g ${TMP_DIR}/greenplum-db-${GPDB_VERSION_FULL}.bin \
    && echo -e "yes\n\nyes\nyes\n" | ${TMP_DIR}/greenplum-db-${GPDB_VERSION_FULL}.bin \
    && mkdir -p $MASTER_DATA_PATH $PRIMARY_DATA_PATH $MIRROR_DATA_PATH \
    && chown -R gpadmin:gpadmin $MASTER_DATA_PATH $PRIMARY_DATA_PATH $MIRROR_DATA_PATH \
    && ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key \
    && ssh-keygen -t ecdsa -f /etc/ssh/ssh_host_ecdsa_key \
    && ssh-keygen -t ed25519 -f /etc/ssh/ssh_host_ed25519_key \
    && cat ${TMP_DIR}/etc_sysctl.conf >> /etc/sysctl.conf \
    && cat ${TMP_DIR}/etc_security_limits.conf >> /etc/security/limits.conf \
    && cat ${TMP_DIR}/etc_selinux_config >> /etc/selinux/config \
    && rm -rf ${TMP_DIR} \
    && chmod +x entrypoint.sh

ENV MASTER_DATA_DIRECTORY $MASTER_DATA_PATH/gpseg-1
ENV PGPORT 5432

# 声明镜像内服务所监听的端口，但是此处只是声明，并不会自动完成端口映射
EXPOSE 5432 22

ENTRYPOINT [ "./entrypoint.sh" ]