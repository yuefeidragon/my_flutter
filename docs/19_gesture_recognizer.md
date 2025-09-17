# Q19：自定义 GestureRecognizer 与低级 PointerEvent 场景（实现与冲突处理）

标准答案要点：
- GestureArena 机制管理手势冲突；自定义 GestureRecognizer 需继承 OneSequenceGestureRecognizer / PrimaryPointerGestureRecognizer，处理 addPointer、handleEvent、acceptGesture、rejectGesture。
- 在复杂触控场景（多指缩放+拖拽）需正确管理主指针和按下顺序，避免在同一时间消费所有 pointer 导致子控件失去事件。

深度解析：
- 解释 GestureArena 的竞赛/优胜机制与如何在 recognizer 中调用 resolve(GestureDisposition.accept) 或 reject。示例展示在 RawGestureDetector 中注册自定义识别器以捕捉特定触发条件。
- 讨论性能与事件转发代价，建议仅在必要时使用低级 API。

加分项：
- 提示如何做到“延迟判断”（deferred decision）以避免误判；以及如何与 Scrollable / GestureDetector 协同。

评分细则（10分）：
- GestureArena 与 recognizer 生命周期 4分；自定义实现要点 4分；冲突处理/实践建议 2分。
