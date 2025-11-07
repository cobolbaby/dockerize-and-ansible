#!/bin/bash

# 获取所有节点的主机名
nodes=$(docker node ls --format "{{.Hostname}}")

# 遍历每个节点
for node in $nodes; do
    echo "---------------------------"
    echo "Node: $node"
    echo "Labels:"

    # 获取该节点的所有 labels（格式为 key=value，每行一个）
    labels=$(docker inspect --format '{{ range $k, $v := .Spec.Labels }}{{ $k }}={{ $v }}{{ "\n" }}{{ end }}' "$node")

    if [ -z "$labels" ]; then
        echo "  (No labels)"
    else
        # 缩进输出
        echo "$labels" | sed 's/^/  /'
    fi
done
