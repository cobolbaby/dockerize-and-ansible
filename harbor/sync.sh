#!/bin/bash
set -e

# 目标: 因为 k8s.gcr.io 直接无法访问，需要同步一份镜像到 harbor

# kubeadm config images list --config /etc/kubernetes/kubeadm-config.yaml
k8s_images=(
    kube-apiserver:v1.23.6
    kube-controller-manager:v1.23.6
    kube-scheduler:v1.23.6
    kube-proxy:v1.23.6
    pause:3.6
    coredns/coredns:v1.8.6
    cpa/cluster-proportional-autoscaler-amd64:1.8.5
    dns/k8s-dns-node-cache:1.21.1
    pause:3.3
)

declare -A repository
repository["source"]="k8s.gcr.io"
repository["target"]="registry.inventec/gcr"

for image in ${k8s_images[@]}
do
	echo "===================== Sync ${image} =====================" 
    docker pull ${repository["source"]}/${image}
    docker tag ${repository["source"]}/${image} ${repository["target"]}/${image}
    docker push ${repository["target"]}/${image}
done

