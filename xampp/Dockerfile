FROM centos:7
LABEL Name=OC
ARG WORK_DIR=/opt/shujuguan/www/oc

# 为后续的 RUN,CMD,entrypoint指令配置工作目录
RUN mkdir -p $WORK_DIR \
    && mkdir -p /tmp/shujuguan

WORKDIR $WORK_DIR

COPY ./pkgs/xampp-linux-x64-5.6.32-0-installer.run .
COPY ./pkgs/redis-3.1.4.tgz .

# 替换镜像源
# 安装基础工具
# 安装XAMPP
# 安装Redis扩展
RUN cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && echo 'Asia/Shanghai' > /etc/timezone \
    && mv /etc/yum.repos.d/CentOS-Base.repo /etc/yum.repos.d/CentOS-Base.repo.backup \
    && curl -o /etc/yum.repos.d/CentOS-Base.repo http://mirrors.163.com/.help/CentOS7-Base-163.repo \
    && rm -rf /var/cache/yum \
    && yum install -y net-tools autoconf gcc automake libtool make \
    && chmod +x ./xampp-linux-x64-5.6.32-0-installer.run \
    && ./xampp-linux-x64-5.6.32-0-installer.run \
    && rm -rf xampp-linux-x64-5.6.32-0-installer.run \
    && tar -zxvf redis-3.1.4.tgz \
    && cd redis-3.1.4/ \
    && /opt/lampp/bin/phpize \
    && ./configure --with-php-config=/opt/lampp/bin/php-config \
    && make && make install \
    && cd - && rm -rf redis-3.1.4*

# 拷贝配置
#COPY ./config/httpd.conf /opt/lampp/etc/httpd.conf
#COPY ./config/php.ini /opt/lampp/etc/php.ini

# 拷贝源码至容器中,但会自动忽略.dockerignore中指明的文件以及文件夹
COPY ./src .
RUN chmod +x run.sh

EXPOSE 80

ENTRYPOINT [ "./run.sh" ]