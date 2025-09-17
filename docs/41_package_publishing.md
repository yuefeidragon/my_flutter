# Q41：Package 发布与语义化版本控制

标准答案要点：
- 使用 semantic versioning，维护 CHANGELOG，自动化发布（pub.dev、内部 registry），并保障向后兼容性。
深度解析：
- 说明 publish 流程、pre-release、breaking change 策略与 API contract tests。
加分项：
- 提供 CI 自动化发布（tag -> publish）与回滚策略。
评分细则（10分）：版本策略 4分；发布自动化 4分；回滚/兼容 2分
