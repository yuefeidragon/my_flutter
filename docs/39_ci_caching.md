# Q39：CI 缓存与构建优化

标准答案要点：
- 利用依赖缓存（pub cache）、gradle 缓存、Docker layer、GitHub Actions cache 减少重复构建时间。
深度解析：
- 说明如何为 Flutter 缓存 pub packages、Android Gradle 缓存和 Xcode 相关缓存配置，以及缓存 key 设计与失效策略。
加分项：
- 讨论构建拆分（affected tests）、artifact reuse 与增量构建策略。
评分细则（10分）：缓存策略 4分；实现细节 4分；构建拆分 2分
