# Q13：网络层设计与缓存策略（拦截器、重试、离线缓存）

标准答案要点：
- 拦截器用于统一处理认证/重试；离线缓存可用 sqflite、hive、或 HTTP cache（Etag/Cache-Control）。
- 设计要考虑幂等性、重试策略（指数退避）、并发请求合并（request deduplication）。

加分项：
- 讨论缓存失效策略（LRU、基于时间/版本）、冲突合并（last-write/merge/CRDT）、以及安全（加密存储 token）。
评分细则（10分）：设计完整性 4分；缓存实现细节 3分；安全/冲突策略 3分
