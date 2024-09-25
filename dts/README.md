## 开源数据同步工具对比

|  | Kettle | DataX | Debezium Connect CDC | Apache Flink CDC Pipeline :white_check_mark: | chunjun | bitsail | Apache inlong | Apache Seatunnel :white_check_mark: | RestCloud | Tapdata | Nifi | DBSyncer
| ------ | ------ | ------ | ------ | ------ | ------ | ------ | ------ | ------ | ------ | ------ | ------ | ------ |
| Github Stars | ![](https://img.shields.io/github/stars/pentaho/pentaho-kettle.svg) | ![](https://img.shields.io/github/stars/alibaba/DataX.svg) | Confluent官方支持 | ![](https://img.shields.io/github/stars/apache/flink-cdc.svg) | ![](https://img.shields.io/github/stars/DTStack/chunjun.svg) | ![](https://img.shields.io/github/stars/bytedance/bitsail.svg) | ![](https://img.shields.io/github/stars/apache/inlong.svg) | ![](https://img.shields.io/github/stars/apache/seatunnel.svg) | 不开源，但有社区版，群电在评估 | ![](https://img.shields.io/github/stars/tapdata/tapdata.svg) | ![](https://img.shields.io/github/stars/apache/nifi.svg) | ![](https://gitee.com/ghi/dbsyncer/badge/star.svg)
| 社区是否活跃 | 虽然老牌，但国内社区一点也不活跃 | 阿里明星项目，一直比较活跃 | 社区成熟也足够活跃 | 社区活跃，但总卡在 PR Review | 最近半年少有更新，维护乏力 | 最近半年已死，字节 KPI 项目 | 是 | 超级活跃，定期有线上Meeting | - | 官方维护居多，社区群很冷清 | 是 | Gitee Top1 的数据同步工具
| 文档是否完善 | 最新版只能去官方网站查，社区资料很少，且教程都是偏使用，源码解析的很少 | 是 | 是 | 3.x 才开始做端到端的数据集成，MySQL 系文档较完善，但 PG 系的差太多 | 略low，维护力度也大不如前 | 最近一年文档没咋更新 | 是，但感觉一直是在腾讯内部孵化，外部用户较少 | 是，公众号每天更新，没见过这么积极的
| 支持 批流一体 | 批 | 批 | 流 | 流 | 批流 | 批流 | 批流 | 批流 | 批流 | 流 | 批流 
| 支持 实时同步 | 开源版不支持，据说商业版支持 | 不支持 | 支持 | 支持 | 支持 | 支持 | 支持 | 支持 | 支持 | 支持 | 目前仅支持了 MySQL，尚未支持 PG、MSSQL
| 支持 DDL 变更同步 | 不支持 | 不支持 | 不支持 | 支持，实现框架已有，目前仅支持了 MySQL | 支持，实现框架已有，目前支持 MySQL/Oracle |  | 支持，但没有统一的接口抽象，代码实现有点乱 | 支持，实现框架已有，目前仅支持了 MySQL | | 文档提到支持，但 issue 中显示暂不支持 |  
| 支持 定时同步 | 支持，但依赖调度系统 | 支持，但依赖调度系统 | 不支持 | 不支持 | 支持，但依赖调度系统 | 支持 | 支持(最新版) | 支持，但依赖调度系统，或依赖 Seatunnel Web | 支持|  | 
| 服务依赖 | Dkron + 增量同步需依赖外部状态存储 | 增量同步需依赖外部状态存储 | Kafka + Kafka Connect + Debezium Source + JDBC Sink，服务依赖最多 | Flink | Flink，增量同步需依赖 Prometheus | Flink | Flink | 最新版本不再强依赖 Flink，Flink仅作为可选的计算引擎之一 |
| 部署方式 | | | | 目前支持远程提交到 Flink Session Cluster，暂不支持 K8S 方式部署，PR 待合并 | | | 底层是 Flink SQL，但用户在管理页面上操作也无需关心 Flink SQL | 支持远程提交到 Flink Session Cluster 以及 K8S 部署方式 |
| 分布式架构 | 虽支持多点部署，但负载均衡需要依赖外部的调度服务 | 虽支持多点部署，但负载均衡需要依赖外部的调度服务 | 支持，依赖 Kakfa Connect 的负载均衡能力 | 支持，需要依赖 Flink 的集群负载均衡(貌似不太靠谱) | 支持，依赖 Flink | 支持，依赖 Flink | 支持，依赖 Flink | 支持，依赖 Flink |  | 
| 是否提供 UI | 支持 | 不支持 | 支持 | 不支持 | 不支持 | 不支持 | 支持，虽然审批逻辑更完善，但试用时核心的数据同步功能用起来总报错，原因未知 | 支持，可以尝鲜
| 支持自动建表 | 不支持 | 不支持 | 不支持 | 支持 | | | | 支持 |  
| 新同步一张表时需要做哪些事 | 新增一条配置 | 增加一套配置 | 修改 Debezium 配置，再增加一套 JDBC 的配置 | 修改现有配置 | 增加一套配置 | 增加一套配置 | 增加一套配置，下游一张表就得对应一个任务 | 修改现有配置
| 支持多表同步共享连接资源 | 不支持 | 不支持 | 不支持 | 支持 | 暂不支持 | 不支持 | 因基于 Flink SQL，暂不支持共享 | 支持
| 数据源连接异常后能否自动恢复 | 依赖调度系统 | 依赖调度系统 | 支持 |
| 支持 Transform | 支持 | 支持 | 支持，配置稍显繁琐，且实际的算法时间复杂度更高 | 支持，且可在一个任务中配置多表的 Transform | 支持，但没讲解文档，从代码库翻到的 | 不支持 |  | 支持，灵活多样，且在最新版 2.3.8 中可在一个任务中配置多表的 Transform
| 支持 One-To-Many Sink | | | | | | | | 支持，且支持分布式事务 | 
| 支持服务可观测 | 需要研究 Kettle 的指标如何解析，无法接入监控系统 | - | 支持 | 支持，但没搜到相关自定义指标说明 | 支持 | ? | 支持，自定义指标最完善 | 自研的计算引擎支持较好，Flink 任务指标有待确认
| 可查询任务执行日志 | 任务粒度，如果一个任务要同步很多表，则会造成日志混杂，不好拆分 | - | 表粒度，如果任务异常，也可访问 API 获取任务异常原因 | Flink 日志都在一块，不好拆 | 表粒度，可监控控制台输出 |  ? | 待查 | Flink 日志都在一块，不好拆，除非使用 Seatunnel 自研的计算引擎
| 支持 MSSQL CDC | 不支持 | 不支持 | 支持 | 暂不支持，虽然有 PR，但卡在 Review 上几个月 | 支持 | 支持 | 支持 |支持
| 支持 PG CDC | 不支持 | 不支持 | 支持 | 暂不支持，虽然有 PR，但卡在 Review 上几个月 | 支持 | ? | 支持 |支持
| 支持 Oracle CDC | 不支持 | 不支持 | 支持 | 暂不支持，虽然有 PR，但卡在 Review 上几个月 | 支持 | ? | 支持 |支持
| 支持 JsonPath Transform | 支持 | | | 不支持 | 不支持 | | | 支持
| 支持 S3File(parquet/json/xml) | 支持 | | | 不支持 | 不支持 | | | 支持
| 支持 GP Sink | 支持，但依赖一个 INSERT/UPDATE 插件，效率奇低 | 支持 | 原生不支持 upsert，需要改造 Sink | 原生不支持 upsert，需要改造 Sink | ...
| 支持全库同步 | 不支持 | 不支持 | 不支持 | 只支持 MySQL | 不支持 | | 只支持 MySQL | |
| 潜在问题 | 不支持同步"删除"事件，要求有一个增量指针 | | 数据库连接数多，服务依赖多，链路长 | 
| 源码仓库 | [pentaho-kettle](https://github.com/pentaho/pentaho-kettle) | [Datax](https://github.com/alibaba/DataX) | - | [flink-cdc](https://github.com/apache/flink-cdc)| [chunjun](https://github.com/DTStack/chunjun) | [bitsail](https://github.com/bytedance/bitsail) | [inlong](https://github.com/apache/inlong) | [seatunnel](https://github.com/apache/seatunnel) | | [tapdata](https://github.com/tapdata/tapdata) | [nifi](https://github.com/apache/nifi/) | [DBSyncer](https://gitee.com/ghi/dbsyncer)
