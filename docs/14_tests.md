# Q14：Tests 深入：Widget/Integration/Golden tests 与 Mock PlatformChannel

标准答案要点：
- Widget tests 模拟 Widget 层，integration tests 在真实 engine 上运行；golden tests 用于 UI 回归。
- Mock PlatformChannel：在测试中用 MethodChannel.setMockMethodCallHandler 模拟 native 返回。

加分项：
- CI 集成时使用 headless device / simulator、管理 golden baseline 与差异阈值、并行化测试策略。
评分细则（10分）：测试分类 3分；mock 与 golden 细节 4分；CI 集成建议 3分
