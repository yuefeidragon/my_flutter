# Q21：Sliver 性能与懒加载策略（SliverList/SliverGrid/SliverPrototypeExtent）

标准答案要点：
- Sliver 提供延迟构建（sliverChildBuilderDelegate）和可回收机制；使用 SliverPrototypeExtentList 可以统一 item extent 优化测量；使用 KeepAlive 或 AutomaticKeepAliveClientMixin 保持页面状态。

深度解析：
- 说明 layout 流程（Sliver constraints/geometry），如何用 cachingExtent、addAutomaticKeepAlives、addRepaintBoundaries 调整性能，何时使用 addSemanticIndexes 防止语义树过大。

加分项：
- 讨论如何做动态 item 高度时的性能陷阱以及 sticky header / pinned appbar 的实现代价。

评分细则（10分）：
- Sliver 概念与关键 API 4分；懒加载/缓存策略 4分；实践建议 2分
