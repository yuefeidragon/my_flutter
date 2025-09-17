# Q24：hot reload / hot restart / AOT / JIT 差异与 release 问题定位

标准答案要点：
- hot reload: 仅替换 Dart 层代码，保留状态；hot restart: 重新启动 Dart VM，重置状态；AOT: release 模式下预编译为本地代码无调试信息，JIT: dev 模式可热 reload。
- release 模式的问题往往与未初始化 native 或 release-specific tree shaking、assert 被移除、不同行为（timing）相关。

深度解析：
- 给出实际排查流程：若在 release 下 bug 出现，优先在 profile/release 模式重现，检查使用到的 assert/debug-only code、platform channel 异常及 tree-shaken code。讨论 symbolication 与 crash reporting 的实践。

加分项：
- 讨论 minification/obfuscation 的影响、如何在 CI 做 AOT 测试覆盖。

评分细则（10分）：
- 区别理解 4分；release 下定位流程 4分；实践建议 2分
