# Q25：内存泄漏定位与修复（DevTools heap snapshot、Retaining Path）

标准答案要点：
- 使用 DevTools 的 Memory/Heap Snapshot 与 Retaining Path 定位泄漏对象，查找长时间持有引用（Stream subscriptions、Timers、Global caches、static collections、GlobalKey misuse）。
- 修复一般通过取消订阅、dispose controllers、使用 weak references 或减少全局状态及使用 scopes。

深度解析：
- 详细说明如何捕获 snapshot、比较 before/after、以及根据 retaining path 找到 root 引用链。列举常见泄漏原因并给出修复代码示例。

加分项：
- 讨论 Dart 的垃圾回收模型与 finalizer 的使用场景（慎用）。

评分细则（10分）：
- 工具使用与流程 4分；常见泄漏源识别 4分；修复策略 2分
