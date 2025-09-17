# Q42：代码生成（build_runner / source_gen）

标准答案要点：
- 通过 source_gen 自动生成重复代码（JSON serialization、DI），注意生成文件的可读性与增量构建。
深度解析：
- 说明 build.yaml 配置、watch 模式、生成与手写代码分离的约定以及生成失败的排查方法。
加分项：
- 讨论生成代码的测试、format 与可维护性策略。
评分细则（10分）：工具使用 4分；工程化建议 4分；测试/维护 2分
