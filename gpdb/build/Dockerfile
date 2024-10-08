FROM registry.inventec/proxy/library/centos:7
LABEL maintainer="Zhang.Xing-Long@inventec.com"

ARG GPDB_VERSION_FULL="6.25.3-rhel7-x86_64"
ARG GPCC_VERSION_FULL="6.9.1-gp6-rhel7-x86_64"
ARG WORK_DIR=/opt/greenplum
ARG TMP_DIR=/tmp/greenplum
ARG MASTER_DATA_PATH=/disk1/gpdata/gpmaster
ARG SEGMENT_DATA_PATH=/{disk1,disk2,disk3,disk4}/gpdata/gpsegment

WORKDIR $WORK_DIR

COPY pkgs $TMP_DIR
COPY etc $TMP_DIR

RUN cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo 'Asia/Shanghai' > /etc/timezone \
    # && mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup \
    # && curl -so /etc/yum.repos.d/CentOS-Base.repo http://mirrors.163.com/.help/CentOS7-Base-163.repo \
    && echo root:WRQGq0KA3UBpwIke | chpasswd \
    && groupadd -g 530 gpadmin \
    && useradd -g 530 -u 530 -m -d /home/gpadmin -s /bin/bash gpadmin \
    && echo gpadmin:Ho1Z9JO7AoC90jA2 | chpasswd \
    && yum install -y ${TMP_DIR}/greenplum-db-${GPDB_VERSION_FULL}.rpm \
    && yum install -y net-tools sudo unzip libcgroup-tools epel-release sshpass \
    && yum clean all \
    && chown -R gpadmin:gpadmin /usr/local/greenplum-db* \
    && mkdir -p $MASTER_DATA_PATH $SEGMENT_DATA_PATH \
    && chown -R gpadmin:gpadmin $MASTER_DATA_PATH $SEGMENT_DATA_PATH \
    && ssh-keygen -t rsa -N '' -f /etc/ssh/ssh_host_rsa_key \
    && ssh-keygen -t ecdsa -N '' -f /etc/ssh/ssh_host_ecdsa_key \
    && ssh-keygen -t ed25519 -N '' -f /etc/ssh/ssh_host_ed25519_key \
    && echo 'gpadmin ALL=(ALL) NOPASSWD:/usr/sbin/sshd,/usr/sbin/cgconfigparser,/usr/sbin/sysctl,/bin/chmod' >> /etc/sudoers \
    && cat ${TMP_DIR}/etc_sysctl.conf >> /etc/sysctl.conf \
    && cat ${TMP_DIR}/etc_security_limits.conf >> /etc/security/limits.conf \
    && echo '* soft nproc 131072' >> /etc/security/limits.d/90-nproc.conf \
    && cat ${TMP_DIR}/etc_selinux_config >> /etc/selinux/config \
    && cat ${TMP_DIR}/.bashrc >> /home/gpadmin/.bashrc \
    && mv ${TMP_DIR}/etc_cgconfig.d_gpdb.conf /etc/cgconfig.d/gpdb.conf \
    && mkdir -p /usr/local/greenplum-cc-${GPCC_VERSION_FULL%%-*} \
    && ln -s /usr/local/greenplum-cc-${GPCC_VERSION_FULL%%-*} /usr/local/greenplum-cc \
    && chown -R gpadmin:gpadmin /usr/local/greenplum-cc* \
    && mv ${TMP_DIR}/greenplum-cc-web-${GPCC_VERSION_FULL}.zip $WORK_DIR \
    && rm -rf ${TMP_DIR}

COPY entrypoint.sh .
RUN chown -R gpadmin:gpadmin $WORK_DIR \
    && chmod +x entrypoint.sh

USER gpadmin
# fix: Environment Variable LOGNAME or USER not set
ENV LOGNAME=gpadmin USER=gpadmin

# 设置默认编码
ENV LANG en_US.UTF-8

# 声明镜像内服务所监听的端口，但是此处只是声明，并不会自动完成端口映射
EXPOSE 5432 22

ENTRYPOINT [ "./entrypoint.sh" ]