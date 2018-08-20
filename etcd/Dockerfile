FROM centos:7

ARG ETCD_VER=v3.3.9

WORKDIR /opt

RUN cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo 'Asia/Shanghai' > /etc/timezone \
    && mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup \
    && curl -so /etc/yum.repos.d/CentOS-Base.repo http://mirrors.163.com/.help/CentOS7-Base-163.repo \
    && yum install -y net-tools wget \
    && yum clean all \
    && wget https://github.com/coreos/etcd/releases/download/${ETCD_VER}/etcd-${ETCD_VER}-linux-amd64.tar.gz \
    && tar -zxvf etcd-${ETCD_VER}-linux-amd64.tar.gz \
    && ln -s etcd-${ETCD_VER}-linux-amd64 etcd \
    && rm etcd-${ETCD_VER}-linux-amd64.tar.gz

ENV PATH /opt/etcd:$PATH

EXPOSE 2379 2380

CMD ["etcd", "--version"]