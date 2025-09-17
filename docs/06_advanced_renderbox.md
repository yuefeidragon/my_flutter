# 题 6：实现自定义 RenderBox（高效绘制、TextPainter 缓存、hitTest、semantics）

## 要点
- 在 performLayout 使用 constraints.constrain
- 在 paint 中重用 TextPainter，不在 paint 中 new TextPainter 每帧
- 实现 hitTestSelf/hitTestChildren 与 describeSemanticsConfiguration
- 使用 markNeedsLayout/markNeedsPaint 的时机
## 加分项
- 说明如何使用 layer cache/raster cache；讨论在复杂子树使用 RepaintBoundary 的权衡。
