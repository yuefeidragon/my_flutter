# Q09：Bloc/Cubit 模式本质、拆分与可测试性（深度解析）

标准答案要点：
- Bloc 是事件驱动的状态机：事件 -> 处理 -> 发出新状态；保持单向数据流和可测试性。Cubit 为轻量级状态容器，直接 emit state。

深度解析：
- 说明如何拆分模块（feature-based blocs），如何写单元测试（把事件发送到 bloc，验证输出 states），以及如何解耦副作用（使用 repository/抽象接口和 mock）。
- 性能与内存：避免在 bloc 中直接持有 BuildContext 或 UI 对象，清理订阅并在 close 时释放资源。

加分项：
- 写出一个简单的 bloc 单元测试示例（使用 StreamQueue 或 expectLater + emitsInOrder）并说明 mock repository 的策略。

评分细则（10分）：
- 模式理解 3分；测试方法 4分；架构拆分与依赖注入 3分。
