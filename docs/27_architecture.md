# Q27：大规模项目架构（模块化/monorepo、版本管理、依赖隔离、渐进迁移）

标准答案要点：
- 模块化（feature modules）与 monorepo 各有利弊；monorepo 易于跨模块 refactor 与 CI，但需强大的工具链（bazel/lerna/gradle composite）。版本管理需采用语义化和清晰的发布策略。

深度解析：
- 讨论如何做依赖隔离（package boundaries、API contracts）、如何在 Flutter 中做插件/模块发布（pub packages / internal registries）、以及渐进迁移（adapter 层、feature flags、双写策略）。

加分项：
- 说明 CI 分层构建（affected tests/changed packages only）、模块契约测试与 API compatibility 检查的实现思路。

评分细则（10分）：
- 架构设计与 trade-offs 5分；工具链与发布策略 3分；渐进迁移计划 2分
