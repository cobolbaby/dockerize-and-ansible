FROM registry.inventec/proxy/python:3.11-alpine
LABEL maintainer="Zhang.Xing-Long@inventec.com"

USER root

# RUN cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
#     && echo 'Asia/Shanghai' > /etc/timezone \
#     && yum install -y net-tools openssh-server \
#     && yum clean all \
#     && echo root:111111 | chpasswd \
#     && ssh-keygen -t rsa -N '' -f /etc/ssh/ssh_host_rsa_key \
#     && ssh-keygen -t ecdsa -N '' -f /etc/ssh/ssh_host_ecdsa_key \
#     && ssh-keygen -t ed25519 -N '' -f /etc/ssh/ssh_host_ed25519_key

RUN pip install --no-cache-dir --upgrade pip -i https://nexus.itc.inventec.net/repository/pypi-proxy/simple/

WORKDIR /usr/src/app

COPY src/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt -i https://nexus.itc.inventec.net/repository/pypi-proxy/simple/

COPY src .

COPY entrypoint.sh .
RUN chmod +x entrypoint.sh

ENTRYPOINT [ "./entrypoint.sh" ]
