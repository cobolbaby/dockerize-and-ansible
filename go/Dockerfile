# Compile
FROM golang:1.13.3 AS builder
WORKDIR /go/src/github.com/cobolbaby/k8s-monitor
COPY . .
RUN make build
RUN mv k8s-monitor /root
# Package
FROM scratch
# scratch是一个空镜像，只能用于构建其他镜像，比如你要运行一个包含所有依赖的二进制文件，如Golang程序，可以直接使用scratch作为基础镜像
WORKDIR /root/
COPY --from=builder /root .
EXPOSE 8080
ENTRYPOINT ["/root/k8s-monitor"]
