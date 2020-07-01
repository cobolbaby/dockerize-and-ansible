FROM tensorflow/tensorflow:1.13.1-gpu-py3-jupyter
LABEL maintainer="Zhang.Xing-Long@inventec.com"

USER root

# Ref: https://docs.docker.com/engine/examples/running_ssh_service/
RUN apt-get update \
    && apt-get install -y net-tools openssh-server \
    && mkdir /var/run/sshd \
    && sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config \
    # SSH login fix. Otherwise user is kicked off after login
    && sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd \
    && rm -rf /var/lib/apt/lists/* \
    && echo root:111111 | chpasswd \
    && pip install --upgrade pip

WORKDIR /usr/src/app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .
RUN chmod +x entrypoint.sh

ENTRYPOINT [ "./entrypoint.sh" ]
