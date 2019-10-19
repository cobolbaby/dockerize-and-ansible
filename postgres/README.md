[TOC]

# Postgres

## 必知要点
### 表空间
### 字符集
### 字段类型
### 临时表
### 视图
### 存储过程
### 逻辑复制
### 流复制
### MVCC

`vacuum`

### Patroni

[Patroni](https://github.com/zalando/patroni): A Template for PostgreSQL HA with ZooKeeper, etcd or Consul

#### 常用命令

- `patronictl list`
- `patronictl show-config`
- `patronictl edit-config`
- `patronictl restart`
- `patronictl failover`

## 最佳实践
### 管理问题
### 秉持原则
#### 降低 Disk I/O
#### 利用 Memory Cache
#### 利用多核优势

### 批量处理
#### 预编译
#### 批量插入
#### 批量更新
#### 批量删除
#### 拷贝表

### 索引优化
#### 索引的左前缀原则

### 数据库中间件
#### 常见数据库中间件及作用
#### 读写分离
#### 分库分表
#### 连接池

### Online DDL

### 数据同步
#### 逻辑复制
#### CDC

### 高可用
#### 硬件要求
#### 版本选择
#### 容量预估
#### 主从节点部署
#### 优化配置项
#### 备份

### 高效运维

收集常见运维脚本

#### 监控管理

[![PostgreSQL监控系统概览](https://github.com/Vonng/pg/raw/master/img/monitor-arch.png)](https://github.com/Vonng/pg/blob/master/mon/overview.md)

#### 日志分析

- [PostgreSQL服务器日志](https://github.com/Vonng/pg/blob/master/admin/logging.md)

## 附录
### 开启慢查询记录
### 权限管理