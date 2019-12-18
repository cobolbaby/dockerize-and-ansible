FROM centos/python-36-centos7
LABEL maintainer="Zhang.Xing-Long@inventec.com"

USER root

RUN cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo 'Asia/Shanghai' > /etc/timezone \
    # && mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup \
    # && curl -so /etc/yum.repos.d/CentOS-Base.repo http://mirrors.163.com/.help/CentOS7-Base-163.repo \
    && yum install -y net-tools openssh-clients openssh-server \
    && yum clean all \
    && echo root:111111 | chpasswd \
    && ssh-keygen -t rsa -N '' -f /etc/ssh/ssh_host_rsa_key \
    && ssh-keygen -t ecdsa -N '' -f /etc/ssh/ssh_host_ecdsa_key \
    && ssh-keygen -t ed25519 -N '' -f /etc/ssh/ssh_host_ed25519_key \
    && pip install --upgrade pip

WORKDIR /usr/src/app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .
RUN chmod +x entrypoint.sh

ENTRYPOINT [ "./entrypoint.sh" ]
