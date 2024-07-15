## 开源数据同步工具对比

|  | Kettle :white_check_mark:  | DataX | Kafka Connect CDC :white_check_mark: | Apache Flink CDC | chunjun | bitsail | Apache inlong | Apache Seatunnel | RestCloud | Tapdata | Nifi | DataPipeline
| ------ | ------ | ------ | ------ | ------ | ------ | ------ | ------ | ------ | ------ | ------ | ------ | ------ |
| Github Stars | 7.5k | 15.5k | | 5.5k | 3.9k | 1.6k | 1.3k | 7.6k | 不开源，但有社区版，群电在评估 | 480 | 4.6k | 商业产品
| 社区是否活跃 | 是 | 是 | 是 | 是 | 近半年更新很少 | 近半年已死 | 是 | 是 | ? | 是 | 是
| 文档是否完善 | 是 | 是 | 是 | 3.x 才开始做端到端的数据集成，所以社区实践文档都较少 | | 最近一年文档没咋更新 | 是，但社区实践案例很少 | 是，公众号也每天更新
| 支持 批流一体 | 否 | 否 | 是 | 否 | 是 | 是 | 是 | 是 | 是 | 否 | 是 
| 支持 实时同步 | 原生不支持，但有二开 | 不支持 | 支持 | 支持 | 支持 | 支持 | 支持 | 支持 | 支持 | 支持 | 目前仅支持了 MySQL，尚未支持 PG、MSSQL
| 支持 DDL 变更同步 | 不支持 | 不支持 | 不支持 | 暂不支持 | 支持 | 支持 | 支持 | 支持 | | 文档提到支持，但 issue 中显示暂不支持 |  
| 支持 定时增量同步 | 支持 | 支持 | 不支持 | 不支持 | 支持 | 支持 | 支持 | 支持 | 支持 | 不支持 | 
| 支持 定义主键 | 支持 | ? | 支持 | ? | ? | ? | ? | 支持 | ?  
| 服务依赖 | Dkron + 增量同步需依赖外部状态存储 | 增量同步需依赖外部状态存储 | Kafka + Kafka Connect + Debezium Source + JDBC Sink | Flink 最新版本 | Flink 1.16.x，与Flink 版本强耦合，增量同步需依赖 Prometheus | Flink | 简配版只需 Flink，完整版依赖项很多 | 最新版本不再强依赖 Flink，Flink仅作为计算引擎，不依赖 flink-cdc 项目 |
| 部署方式 | | | | 只支持 Flink Session Mode，但有 PR 正在推进对 Application Mode 的支持 | | | Flink SQL 方式，但带有页面 | 支持 Flink on K8S Application Mode 的部署方式 |
| 分布式架构 | 虽支持多点部署，但负载均衡需要依赖外部的调度服务 | 虽支持多点部署，但负载均衡需要依赖外部的调度服务 | 支持，依赖 Kakfa Connect 的负载均衡能力 | 支持，需要依赖 Flink 的集群负载均衡(貌似不太靠谱) | 支持，依赖 Flink | 支持，依赖 Flink | 支持，依赖 Flink | 支持，依赖 Flink |  | 
| 是否提供 UI | 支持 | 不支持 | 支持 | 不支持 | 不支持 | 不支持 | 支持 | 支持
| 新增一张同步的表 | 配置中心新增配置 | 增加一套配置 | 修改Debezium配置，再增加一套JDBC的配置 | 修改现有配置 | 增加一套配置 | 增加一套配置 | ？现有配置  | 修改现有配置
| 支持多表同步共享连接资源 | 不支持 | 不支持 | 不支持 | 支持 | 暂不支持 | 不支持 | 支持 | 支持
| 数据源连接异常后能否自动恢复 | 依赖调度系统 | 依赖调度系统 | 依赖服务巡检 | 
| 支持全库同步 | 不支持 | 不支持 | 不支持 | 
| 支持 Transform | 支持 | 支持 | 支持，但不够灵活 | 支持 | 支持 | 不支持 | 支持 | 支持
| 如何二开 Sink | | | | | | | | | 不开源，所以不支持
| 支持可观测 | 不支持 | - | 支持 | 支持，但没搜到相关自定义指标说明 | 支持 | ? | 支持，还自定义了指标 | 支持
| 可查询任务执行日志 | 任务粒度，如果一个任务要同步很多表，则会造成日志混杂，不好拆分 | - | 表粒度，如果任务异常，也可访问 API 获取任务异常原因 | Flink 日志都在一块，不好拆 | 表粒度，可监控控制台输出 |  ? | 待查 | Flink 日志都在一块，不好拆，不确定 Rest API 能否做到表粒度的拆分
| 支持 MSSQL CDC | 不支持 | 不支持 | 支持 | 暂不支持，但也有 PR | 支持 | 支持 | 支持 |支持
| 支持 PG CDC | 不支持 | 不支持 | 支持 | 暂不支持，但也有 PR | 支持 | 不支持 | 支持 |支持
| 支持 GP Sink | 支持 | 支持 | 原生不支持 upsert，需要改造 sink | 原生不支持 upsert，需要改造 sink | ...
| 支持其他哪些数据源 | | 
| 潜在问题 | 不支持同步"删除"事件，要求有一个增量指针 | | 数据库连接数多，服务依赖多，链路长 | 
| 源码仓库 | [pentaho-kettle](https://github.com/pentaho/pentaho-kettle) | [Datax](https://github.com/alibaba/DataX) | - | [flink-cdc](https://github.com/apache/flink-cdc)| [chunjun](https://github.com/DTStack/chunjun) | [bitsail](https://github.com/bytedance/bitsail) | [inlong](https://github.com/apache/inlong) | [seatunnel](https://github.com/apache/seatunnel) | | [tapdata](https://github.com/tapdata/tapdata) | [nifi](https://github.com/apache/nifi/)