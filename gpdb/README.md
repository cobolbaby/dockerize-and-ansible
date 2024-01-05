### 构建部署须知:

1. 通过 https://network.pivotal.io/products/vmware-greenplum 下载商业版本 或从 https://github.com/greenplum-db/gpdb/releases 下载最新开源版本，保存与 build 目录下的 pkgs 子目录下
2. 执行 build.sh 或者 build-ce.sh 脚本构建镜像
3. 采用 Swarm 构建多主机的容器集群，并创建 Overlay 网络
3. 理清 deploy.sh 中需要执行的操作，以及执行顺序，由于 deploy.sh 依赖 Ansible 进行部署，故需自行完善 inventory 资产配置文件