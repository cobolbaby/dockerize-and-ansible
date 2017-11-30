FROM node:6.11
ARG WORK_DIR=/opt/shujuguan/startpoint

# development/production
ARG NODE_ENV=production
ENV NODE_ENV $NODE_ENV

# 设定时区，确保时间一致
RUN /bin/cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo 'Asia/Shanghai' > /etc/timezone \
    && mkdir -p $WORK_DIR

# 为后续的 RUN,CMD,entrypoint指令配置工作目录
WORKDIR $WORK_DIR

# 使用cnpm安装依赖
COPY package.json $WORK_DIR
RUN npm config set registry https://registry.npm.taobao.org \
    && npm install -g pm2 \
    && npm install --production

# 拷贝源码至容器中,但会自动忽略.dockerignore中指明的文件以及文件夹
COPY ./src $WORK_DIR
RUN chmod +x run.sh

# 声明镜像内服务所监听的端口，但是此处只是声明，并不会自动完成端口映射
EXPOSE 8888

ENTRYPOINT [ "./run.sh" ]