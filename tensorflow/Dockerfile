FROM tensorflow/tensorflow:1.13.1-gpu-py3-jupyter
LABEL maintainer="Zhang.Xing-Long@inventec.com"

USER root

RUN apt-get update \
    && apt-get install -y net-tools openssh-client openssh-server \
    && rm -rf /var/lib/apt/lists/* \
    && echo root:111111 | chpasswd \
    && pip install --upgrade pip

WORKDIR /usr/src/app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY . .
RUN chmod +x entrypoint.sh

ENTRYPOINT [ "./entrypoint.sh" ]
