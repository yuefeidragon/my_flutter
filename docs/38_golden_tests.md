# Q38：Golden Tests 与像素级回归测试

标准答案要点：
- Golden tests 用于 UI 像素回归，通过对比 baseline image 来检测 UI 变更；需固定设备像素比、字体与 locale，使用 golden 文件管理版本。
深度解析：
- 说明如何在测试中使用 matchesGoldenFile、如何生成 baseline、在 CI 中如何管理差异阈值与失败策略。
加分项：
- 讨论不同设备分辨率、字体渲染差异与跨平台 golden 的兼容策略（使用容器化或统一测试 runner）。
评分细则（10分）：工具与流程 4分；CI/管理策略 4分；跨平台兼容 2分
