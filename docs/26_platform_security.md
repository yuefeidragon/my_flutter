# Q26：PlatformChannel 与本地接口安全（输入校验、签名/权限、传输大文件策略）

标准答案要点：
- Platform channel 的输入需做严格校验；对敏感操作需在 native 端进行权限/签名验证；大文件应通过临时文件路径传递而非直接在内存中传输。

深度解析：
- 讨论 native 权限流（Android runtime permission）、file lifecycle（temp dir）、以及如何做 integrity checks（hash 校验）。建议把 heavy work 放在 native/background thread 并返回文件路径或分片流（EventChannel/streaming）。

加分项：
- 讨论加密传输、签名验证与 native side 的 rate limiting、throttling 策略。

评分细则（10分）：
- 安全边界与校验 4分；大文件与性能策略 3分；实践建议 3分
