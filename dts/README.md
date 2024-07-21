## 开源数据同步工具对比

|  | Kettle | DataX | Kafka Connect CDC | Apache Flink CDC Pipeline :white_check_mark: | chunjun | bitsail | Apache inlong | Apache Seatunnel :white_check_mark: | RestCloud | Tapdata | Nifi | DataPipeline
| ------ | ------ | ------ | ------ | ------ | ------ | ------ | ------ | ------ | ------ | ------ | ------ | ------ |
| Github Stars | 7.5k | 15.5k | Confluent官方支持 | 5.5k | 3.9k | 1.6k | 1.3k | 7.6k | 不开源，但有社区版，群电在评估 | 480 | 4.6k | 商业产品
| 社区是否活跃 | 一般般 | 是 | 是 | 是 | 一般般 | 近半年已死 | 是 | 是，定期有线上Meeting | - | 官方维护居多，社区群很冷清 | 是
| 文档是否完善 | 最新版只能去官方网站查，社区资料很少 | 是 | 是 | 3.x 才开始做端到端的数据集成，所以社区实践文档都较少 | | 最近一年文档没咋更新 | 是，但社区实践案例很少 | 是，公众号也每天更新
| 支持 批流一体 | 否 | 否 | 是 | 否 | 是 | 是 | 否 | 是 | 是 | 否 | 是 
| 支持 实时同步 | 原生不支持，但有二开 | 不支持 | 支持 | 支持 | 支持 | 支持 | 支持 | 支持 | 支持 | 支持 | 目前仅支持了 MySQL，尚未支持 PG、MSSQL
| 支持 DDL 变更同步 | 不支持 | 不支持 | 不支持 | 暂不支持 | 支持，已有抽象接口，目前支持 MySQL/Oracle | 支持，但没细看具体支持哪个 | 支持，但这块没有统一的接口抽象，代码实现有点乱 | 支持，实现框架已有，目前仅支持了 MySQL | | 文档提到支持，但 issue 中显示暂不支持 |  
| 支持 定时同步 | 支持，依赖调度系统 | 支持，依赖调度系统 | 不支持 | 不支持 | 支持，依赖调度系统 | 支持 | 不支持 | 支持，依赖调度系统  | 支持|  | 
| 服务依赖 | Dkron + 增量同步需依赖外部状态存储 | 增量同步需依赖外部状态存储 | Kafka + Kafka Connect + Debezium Source + JDBC Sink | Flink 最新版本 | Flink 1.16.x，与Flink 版本强耦合，增量同步需依赖 Prometheus | Flink | 依赖 Flink CDC 项目，文档提到只支持 Flink 1.13 和 1.15 两个版本，略低 | 最新版本不再强依赖 Flink，Flink仅作为计算引擎，不依赖 flink-cdc 项目 |
| 部署方式 | | | | 可以通过配置 flink-conf.yaml 来实现远程提交到 Flink Session Cluster，暂不支持提交 yaml 文件给 K8S | | | 底层是 Flink SQL，但用户在管理页面上操作也无需关心 Flink SQL | 支持 Flink on K8S Application Mode 的部署方式 |
| 分布式架构 | 虽支持多点部署，但负载均衡需要依赖外部的调度服务 | 虽支持多点部署，但负载均衡需要依赖外部的调度服务 | 支持，依赖 Kakfa Connect 的负载均衡能力 | 支持，需要依赖 Flink 的集群负载均衡(貌似不太靠谱) | 支持，依赖 Flink | 支持，依赖 Flink | 支持，依赖 Flink | 支持，依赖 Flink |  | 
| 是否提供 UI | 支持 | 不支持 | 支持 | 不支持 | 不支持 | 不支持 | 支持，虽然审批逻辑更完善，但核心的数据同步功能用起来总报错，也不知道哪的问题 | 支持，新支持，看 Issue 有一些影响使用的问题
| 新同步一张表时需要做哪些事 | 新增一条配置 | 增加一套配置 | 修改Debezium配置，再增加一套JDBC的配置 | 修改现有配置 | 增加一套配置 | 增加一套配置 | 增加一套配置，下游一张表就得对应一个任务 | 修改现有配置
| 支持多表同步共享连接资源 | 不支持 | 不支持 | 不支持 | 支持 | 暂不支持 | 不支持 | 因基于 Flink SQL，暂不支持共享 | 支持
| 数据源连接异常后能否自动恢复 | 依赖调度系统 | 依赖调度系统 | 依赖服务巡检 |
| 支持自动建表 | 不支持 | 不支持 | 不支持 | 支持 | | | | 支持 |  
| 支持全库同步 | 不支持 | 不支持 | 不支持 | 暂时只支持 MySQL | 不支持 | | 暂时只支持 MySQL | 支持 |
| 支持 Transform | 支持 | 支持 | 支持，配置稍显繁琐，且实际的算法时间复杂度更高 | 支持，也支持多表的 Transform 配置在一个任务中 | 支持，但只支持单表 | 不支持 | 支持，但不支持一个任务配置多个表的 Transform | 支持，但暂不支持一个任务配置多个表的 Transform
| 如何二开 Sink | | | | | | | | | 不开源，所以不支持
| 支持可观测 | 不支持 | - | 支持 | 支持，但没搜到相关自定义指标说明 | 支持 | ? | 支持，还自定义了指标 | 支持
| 可查询任务执行日志 | 任务粒度，如果一个任务要同步很多表，则会造成日志混杂，不好拆分 | - | 表粒度，如果任务异常，也可访问 API 获取任务异常原因 | Flink 日志都在一块，不好拆 | 表粒度，可监控控制台输出 |  ? | 待查 | Flink 日志都在一块，不好拆，不确定 Rest API 能否做到表粒度的拆分
| 支持 MSSQL CDC | 不支持 | 不支持 | 支持 | 暂不支持，但也有 PR | 支持 | 支持 | 支持 |支持
| 支持 PG CDC | 不支持 | 不支持 | 支持 | 暂不支持，但也有 PR | 支持 | 不支持 | 支持 |支持
| 支持 GP Sink | 支持 | 支持 | 原生不支持 upsert，需要改造 sink | 原生不支持 upsert，需要改造 sink | ...
| 支持其他哪些数据源 | | 
| 潜在问题 | 不支持同步"删除"事件，要求有一个增量指针 | | 数据库连接数多，服务依赖多，链路长 | 
| 源码仓库 | [pentaho-kettle](https://github.com/pentaho/pentaho-kettle) | [Datax](https://github.com/alibaba/DataX) | - | [flink-cdc](https://github.com/apache/flink-cdc)| [chunjun](https://github.com/DTStack/chunjun) | [bitsail](https://github.com/bytedance/bitsail) | [inlong](https://github.com/apache/inlong) | [seatunnel](https://github.com/apache/seatunnel) | | [tapdata](https://github.com/tapdata/tapdata) | [nifi](https://github.com/apache/nifi/)
