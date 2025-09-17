# Q69：Lint、格式化与代码健康门（pre-commit / CI gates）

标准答案要点：
- 强制 lint/format、静态分析与测试作为提交门槛；使用 tools (dart analyze, lints package) 统一规则。
深度解析：
- 讨论 auto-fix、pre-commit hooks、渐进引入严格规则与 false-positive 管理。
加分项：
- 结合 CI 报表与 tech debt 跟踪实现长期改进。
评分细则（10分）：工具与规则 4分；pipeline 集成 4分；治理 2分
