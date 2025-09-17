# 题 5：CI 流程设计（静态检查、单元/Widget 测试、iOS 无签名构建、Simulator 上的 integration_test）

## 标准答案要点
- Pipeline: checkout -> pub get -> analyze -> test -> build ios --no-codesign (macos) -> (optional) run integration_test on simulator.
- Certificates & profiles: use secrets/fastlane match / App Store Connect API keys; store secrets in CI provider.
## 深度解析
（包括 xcrun simctl 启动模拟器、如何解密证书、如何安全管理 secrets、如何保存 artifacts、如何对热更做回滚策略）
## 加分项
- 提到 use of GitHub Actions matrix for multiple flutter versions/architectures；如何在 CI 中运行 flutter test for each sample project.
## 评分细则
- Pipeline 完整性 4 分；macOS/simulator 细节 3 分；证书/安全运维 3 分
