# Compile
FROM golang:1.13.3 AS builder
WORKDIR /go/src/github.com/cobolbaby/k8s-monitor
# 拷贝Go的包管理文件
COPY go.mod go.sum .
# 下载依赖包中的依赖库
RUN go mod download
COPY . .
RUN make build
RUN mv k8s-monitor /root
# Package
FROM centos:7
WORKDIR /root/
COPY --from=builder /root .
EXPOSE 8080
ENTRYPOINT ["/root/k8s-monitor"]
