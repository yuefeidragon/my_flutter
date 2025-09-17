# Q08：InheritedWidget / Provider 原理与性能优化（深度解析）

标准答案要点：
- InheritedWidget 负责将数据沿 Element 树向下传播，Element 会注册依赖（dependOnInheritedWidgetOfExactType），在 InheritedWidget 更新时触发相关 Element rebuild。
- Provider 类库基于 InheritedWidget 封装了便捷的注入/订阅机制（ChangeNotifierProvider、Selector 等用于性能优化）。

深度解析：
- 说明 Element 如何在调用 dependOnInheritedWidgetOfExactType 时记录依赖并在 InheritedElement.changeDependencies 时触发 rebuild。
- 性能优化：使用 Selector/Consumer 或 context.read/listen:false 来控制重建范围；避免在高频更新使用全局 Provider；用 const、RepaintBoundary、ValueListenableBuilder 做局部更新。

加分项：
- 解释 Selector 的实现思路（比较 old/new select 值以决定 rebuild）；说明 Provider.of(context, listen:false) 在 initState 中的安全用法。
- 讨论 Provider 与 Service Locator（GetIt）在可测性与全局状态上的权衡。

评分细则（10分）：
- 原理描述（InheritedWidget/Element 依赖注册）4分；
- Provider 封装与性能优化（Selector/Consumer/listen:false）3分；
- 加分项（源码/实现细节/测试建议）3分。

验证提示：
- 示例演示局部 rebuild 与 Selector 行为；用 DevTools 的 rebuild profiler 验证重建范围。
