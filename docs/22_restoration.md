# Q22：状态恢复（RestorationMixin、PageStorage、持久化恢复设计）

标准答案要点：
- RestorationMixin 与 restorationId 支持在系统杀死后恢复 UI 状态；PageStorage 用于简单滚动位置保存；对于复杂场景可结合 persisted storage（sqlite、shared_preferences）手工恢复。

深度解析：
- 说明 RestorationMixin 的 restoreState/restoreBucket 工作流，如何为自定义 State 保存/恢复值，注意 only supported on platforms with restoration support。

加分项：
- 讨论跨进程/跨版本的数据兼容性、以及如何设计恢复策略以避免安全/隐私问题。

评分细则（10分）：
- API 与流程理解 5分；实践与边界条件 3分；安全/数据兼容 2分
