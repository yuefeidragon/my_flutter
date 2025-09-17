# Q40：Monorepo 在 Flutter 项目中的工具链与实践

标准答案要点：
- Monorepo 优点包括集中管理、跨包 refactor，但需要工具（bazel、melos）管理包依赖与 CI。
深度解析：
- 说明 melos、pub global activate、affected tests、依赖隔离与包发布流程。
加分项：
- 讨论 CI 分层、权限控制与规模化构建策略。
评分细则（10分）：工具链 4分；发布/CI 策略 4分；实践建议 2分
