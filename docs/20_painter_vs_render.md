# Q20：CustomPainter vs RenderObject 深入比较与选型建议

标准答案要点：
- CustomPainter 适用于局部绘制且与现有 Widget tree 一起工作（Painter 与 Picture），RenderObject 更底层适用于需要控件布局参与、复杂 hitTest、语义或与子 RenderObject 协同的场景。

深度解析：
- 介绍 CustomPainter 的 repaint/shouldRepaint 与如何用 RepaintBoundary 限制重绘；RenderObject 的优点是可以参与 layout 阶段并做精细控制。示例比较性能权衡：若需复杂布局/多子节点建议用 RenderObject，否则 CustomPainter 较快上手。

加分项：
- 说明如何把重复绘制逻辑缓存为 Picture 或 Layer，避免频繁重绘。

评分细则（10分）：
- 选型与原理 5分；实现差异与性能权衡 3分；缓存/优化策略 2分
