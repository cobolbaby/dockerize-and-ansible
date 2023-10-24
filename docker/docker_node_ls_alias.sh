#!/bin/bash

# 获取节点列表
nodes=$(docker node ls --format "{{.Hostname}}")

# 循环遍历节点
for node in $nodes; do
    # 执行 docker inspect node 命令获取节点的alias
    alias=$(docker inspect --format "{{.Spec.Labels.alias}}" $node)
    
    # 输出节点的alias
    echo "Node ID: $node, Alias: $alias"
done