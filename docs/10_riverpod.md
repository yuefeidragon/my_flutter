# Q10：Riverpod 原理（ProviderContainer、ScopedProviders）与高级用法（family、autoDispose）

标准答案要点：
- Riverpod 将 provider 的生命周期与读取解耦，可以通过 ProviderContainer 在非 Widget 环境中读取 provider；family 用于参数化 provider，autoDispose 自动回收资源。

深度解析：
- 说明与 Provider 的区别（context-free、测试友好、依赖注入的可组合性），并示例如何在测试中用 ProviderContainer 做隔离测试。

加分项：
- 说明监听 provider 变化的高阶场景（override、refresh）和 performance tips（避免不必要的 provider 链）。
评分细则（10分）：
- 原理与对比 4分；family/autoDispose 实战 3分；测试与容器用法 3分。
