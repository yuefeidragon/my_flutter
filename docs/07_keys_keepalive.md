# 题 7：Key 与 KeepAlive 的进阶用法（列表重排、PageView 保持、AutomaticKeepAliveClientMixin）

## 要点
- Key 决定 identity，ValueKey/ObjectKey/GlobalKey/UniqueKey 的差异
- AutomaticKeepAliveClientMixin 与 PageStorage 的适用场景（Tab 页面/懒加载）及实现方式
## 加分项
- 讨论 GlobalKey 拥有 State 引用的场景与代价；如何避免内存/性能问题
