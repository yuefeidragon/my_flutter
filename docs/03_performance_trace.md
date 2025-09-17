# 题 3：Flutter 性能排查流程（从发现 jank 到定位并修复） — 深度解析

## 标准答案要点
- 指标：帧时长（16ms 基线）、UI/GPU 分时、内存占用、CPU 火焰图等。
- 流程：收集（用户/监控）→ reproduce（Profile timeline）→ 定位（UI thread vs GPU vs IO）→ 优化（局部重建、RepaintBoundary、图片优化、Isolate/compute）→ 验证（Profile 比较）。
## 深度解析
（略——文档应包含 DevTools 使用步骤、常见 root causes、示例修复策略如把 heavy compute 移到 isolate、预解码图片、避免 build 中同步 IO）
## 加分项
- 详细说明 timeline 的 UI vs raster 列，如何查看“missed frame”并展开 frame events；
- 给出 isolate 与 compute 的对比，如何衡量开销与数据复制成本；
- 提供 Flame chart 解读示例。
## 评分细则
- 流程与工具熟悉：4 分；DevTools 操作细节：3 分；修复策略与示例：3 分
