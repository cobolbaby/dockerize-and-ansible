FROM centos:7

ARG NODE_DIR=/opt
WORKDIR $NODE_DIR

RUN cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo 'Asia/Shanghai' > /etc/timezone \
    && yum install -y net-tools wget \
    && yum clean all \
    && wget https://nodejs.org/dist/v8.11.3/node-v8.11.3-linux-x64.tar.xz \
    && xz -d node-v8.11.3-linux-x64.tar.xz \
    && tar -xvf node-v8.11.3-linux-x64.tar \
    && ln -s node-v8.11.3-linux-x64 node \
    && rm node-v8.11.3-linux-x64.tar

# 设置环境变量
ENV LANG en_US.UTF-8
ENV PATH /bin:/usr/sbin:/usr/local/sbin:/usr/local/share/bin:/opt/node/bin:$PATH
ENV NODE_ENV production

ARG WORK_DIR=/opt/genesis
RUN mkdir -p $WORK_DIR
WORKDIR $WORK_DIR

# 使用taobao npm安装依赖
COPY package.json .
RUN npm config set registry https://registry.npm.taobao.org \
    && npm install --production \
    && npm cache clean --force

# 拷贝源码至容器中,但会自动忽略.dockerignore中指明的文件以及文件夹
COPY ./dist .
RUN chmod +x run.sh

# 声明镜像内服务所监听的端口，但是此处只是声明，并不会自动完成端口映射
EXPOSE 8888

ENTRYPOINT [ "./run.sh" ]
