FROM centos:7

# Argument
ARG GPDB_VERSION_FULL="4.3.25.1-rhel5-x86_64"
ARG WORK_DIR=/opt/greenplum
ARG PKG_DIR=/tmp/pkgs

RUN mkdir -p $WORK_DIR
WORKDIR $WORK_DIR

COPY pkgs/* $PKG_DIR/
COPY run.sh .

RUN cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo 'Asia/Shanghai' > /etc/timezone \
    && mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup \
    && mv ${PKG_DIR}/CentOS7-Base-163.repo /etc/yum.repos.d/CentOS-Base.repo \
    && yum install -y net-tools \
    && yum clean all

RUN groupadd gpadmin \
    && useradd -g gpadmin -m -d /home/gpadmin -s /bin/bash gpadmin \
    && echo gpadmin:gpadmin | chpasswd \
    && chown -R gpadmin:gpadmin $WORK_DIR \
    && sed -i s/"more << EOF"/"cat << EOF"/g ${PKG_DIR}/greenplum-db-${GPDB_VERSION_FULL}.bin \
    && echo -e "yes\n\nyes\nyes\n" | ${PKG_DIR}/greenplum-db-${GPDB_VERSION_FULL}.bin \
    && rm -f ${PKG_DIR} \
    && chmod +x run.sh \
    # && copy optimize configuration \
    && service ssh start

ENV LANG en_US.UTF-8
RUN source /usr/local/greenplum-db/greenplum_path.sh
ENV MASTER_DATA_DIRECTORY /data/gpdb/master
ENV PGPORT 5432
ENV PGDATABASE ictlog

# 声明镜像内服务所监听的端口，但是此处只是声明，并不会自动完成端口映射
EXPOSE 5432

CMD [ "/bin/bash" ]
ENTRYPOINT [ "./run.sh" ]