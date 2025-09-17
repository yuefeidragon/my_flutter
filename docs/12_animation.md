# Q12：Flutter 动画深入（Implicit vs Explicit、性能与复用）

标准答案要点：
- Implicit animations（AnimatedContainer 等）适合简单属性动画；Explicit（AnimationController + Tween）适合复杂、可控动画。
- 注意 lifecycle（dispose controller），复用 controller 与 AnimationController 的 vsync 使用（TickerProvider）以节省资源。

加分项：
- 如何使用 AnimationController.forward/reverse、使用 CurvedAnimation 复用 easing、避免在 build 中创建 controller。
评分细则（10分）：分类理解 3分；API 使用与生命周期 4分；性能与复用 3分
