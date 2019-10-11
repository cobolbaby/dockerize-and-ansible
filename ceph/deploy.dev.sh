#!/bin/bash

docker run -d --net=host \
-v /etc/ceph:/etc/ceph \
-v /data/ceph:/var/lib/ceph \
-e MON_IP=10.191.7.11 \
-e CEPH_PUBLIC_NETWORK=10.191.7.0/24 \
--restart always \
registry.inventec/hub/ceph/daemon:v3.2.5-stable-3.2-mimic-centos-7 mon

sudo scp -r /etc/ceph dev@10.191.7.12:/tmp/
sudo scp -r /data/ceph/bootstrap* dev@10.191.7.12:/tmp/
sudo mv /tmp/ceph /etc/
sudo chown -R 167:167 /etc/ceph
sudo mkdir -p /data/ceph/
sudo mv /tmp/bootstrap* /data/ceph/
sudo chown -R 167:167 /data/ceph

docker run -d --net=host \
-v /etc/ceph:/etc/ceph \
-v /data/ceph:/var/lib/ceph \
-e MON_IP=10.191.7.12 \
-e CEPH_PUBLIC_NETWORK=10.191.7.0/24 \
--restart always \
registry.inventec/hub/ceph/daemon:v3.2.5-stable-3.2-mimic-centos-7 mon

docker run -d --net=host \
-v /etc/ceph:/etc/ceph \
-v /data/ceph:/var/lib/ceph \
-e MON_IP=10.191.7.14 \
-e CEPH_PUBLIC_NETWORK=10.191.7.0/24 \
--restart always \
registry.inventec/hub/ceph/daemon:v3.2.5-stable-3.2-mimic-centos-7 mon

# 多点执行
docker run -d --net=host \
--privileged=true \
--pid=host \
-v /etc/ceph:/etc/ceph \
-v /data/ceph:/var/lib/ceph \
-v /dev:/dev \
-e OSD_TYPE=directory \
--restart always \
registry.inventec/hub/ceph/daemon:v3.2.5-stable-3.2-mimic-centos-7 osd

docker run -d --net=host \
-v /etc/ceph:/etc/ceph \
-v /data/ceph:/var/lib/ceph \
--restart always \
registry.inventec/hub/ceph/daemon:v3.2.5-stable-3.2-mimic-centos-7 mgr

docker run -d --net=host \
-v /etc/ceph:/etc/ceph \
-v /data/ceph/:/var/lib/ceph/ \
-e CEPHFS_CREATE=1 \
--restart always \
registry.inventec/hub/ceph/daemon:v3.2.5-stable-3.2-mimic-centos-7 mds

docker run -d --net=host \
-v /etc/ceph:/etc/ceph \
-v /data/ceph/:/var/lib/ceph/ \
--restart always \
registry.inventec/hub/ceph/daemon:v3.2.5-stable-3.2-mimic-centos-7 rgw

# ceph mgr module enable dashboard
# ceph config set mgr mgr/dashboard/server_addr 0.0.0.0
# ceph config set mgr mgr/dashboard/server_port 8080
# ceph dashboard set-login-credentials admin admin          
# radosgw-admin user create --uid=tester --display-name=tester --system
# ceph dashboard set-rgw-api-access-key GW7WXHQ66LKUKHXHAKPM
# ceph dashboard set-rgw-api-secret-key zqAdafdROLbRYENvM5CCUNANEN8oeetGCX797zBn
