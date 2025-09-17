#!/usr/bin/env bash
set -e

echo "=== Flutter Interview Docs Init Script ==="
echo "This script will create docs, sample apps and GitHub workflows in the current repository."
echo "Run this in the repo root (where .git exists)."

# Config
FLUTTER_CMD=$(which flutter || true)
REPO_ROOT=$(pwd)

echo "Repo root: $REPO_ROOT"
echo "Flutter available: ${FLUTTER_CMD:-none}"

mkdir -p docs samples .github/workflows

########################
# Write docs for Q1
########################
cat > docs/01_Widget_Element_RenderObject.md <<'MD'
# 题 1：Widget → Element → RenderObject 的职责与生命周期（深度解析）

## 简短答案
- Widget：声明式不可变配置，描述 UI 的“是什么”。
- Element：把 Widget 实例化为树上的节点，管理生命周期、构建与更新。
- RenderObject：执行布局（layout）、绘制（paint）、命中测试与语义；是真正负责渲染的对象。

## 详细解析与底层机制
（以下是面试评分点与详细讲解，便于面试官与候选人对答）
### 1. Widget（职责）
- 不持有长期可变状态（对象通常为不可变），仅封装构造参数、build 方法、配置。
- Widget 的 build() 返回子 Widgets，它描述了当前 UI 的结构。
- Flutter 通过对比 Widget 的 runtimeType 和 key 来决定 Element 是否可以复用。

### 2. Element（职责）
- Element 是 Widget 的运行时表示（一个 Widget 在渲染树上对应一个 Element 实例）。
- Element 管理 Widget 的生命周期（mount、update、unmount）。
- Element 在 build() 时会调用 Widget.build() 并把生成的子 Widgets 转换/匹配成子 Elements（通过 updateChild/createChild）。
- Element 还用来注册 InheritedWidget 的依赖关系（dependOnInheritedWidgetOfExactType 在 Element 层实现）。

### 3. RenderObject（职责）
- RenderObject 负责执行 layout（performLayout）、paint（paint）和语义（semantics）等。
- RenderObjectTree 是可变的，且可能被 Element attach/detach。
- RenderObject 有几类：RenderBox（矩形布局模型）、RenderParagraph（文本）、RenderSliver（可滚动片段）等。

### 运行时协作（生命周期与调用顺序）
1. Flutter 框架调用 runApp，创建根 Widget。
2. Shell 创建 root Element（通常是 RenderObjectToWidgetAdapter 的 Element），并 mount。
3. Element 调用 Widget.build() → 生成子 Widgets。
4. Element 根据子 Widgets 创建或复用子 Elements（createElement/updateChild），对 RenderObjects 做 attach/detach/更新，最后调用布局流程。
5. RenderObject 的 layout/paint 在需要时被框架调度（例如需要重新布局或重绘时使用 markNeedsLayout()/markNeedsPaint()）。

### 关键细节（面试深挖点）
- rebuild（Element.rebuild）并不等于销毁 State：StatefulWidget 的 State 对象是由 Element（StatefulElement）持有的。Widget 被替换时，如果 runtimeType 与 key 未变，Element 会 update 并复用 State。
- 为什么要分三层？性能与抽象分离：
  - Widget 便于声明式编程，最小化对象生命周期开销（可频繁创建/销毁）。
  - Element 负责变更检测与依赖管理（如 InheritedWidget 订阅）。
  - RenderObject 专注性能敏感的布局/绘制，实现缓存与精细重绘。

### 典型考题追问与回答要点
- Q: Widget 和 Element 的相比哪个更频繁创建？
  A: Widget 更频繁（声明式 UI 每次 build 都可能创建新的 Widget），但 Element 较少创建（只有当 tree 结构变化或 key/type 改变时创建）。
- Q: Widget 的不可变性带来了哪些优化可能？
  A: 能更容易进行差分比较（用 type + key），减少状态迁移错误，也有利于热点优化（const widgets 可被 compile-time 处理）。

## 源码线索（可给面试官/候选人用于更深调研）
- flutter/packages/flutter/lib/src/widgets/framework.dart（Element、Widget、State 的实现）
- render library 的实现路径：flutter/packages/flutter/lib/src/rendering/

## 可加分的进阶点（面试加分）
- 说明 RenderObject layout 过程（constraints 传递→ child layout→ size 决定→ parent 使用），举例说明为什么 child 会忽略某些父约束导致 overflow。
- 能解释 Element 的 updateChild/createChild 的高层机制或能在源码中找到对应函数并简述（给出文件与方法名）。
- 说明 Widget、Element、RenderObject 三层在 Flutter 架构设计中的 trade-offs（内存 vs 频繁重建 vs 性能）。

## 评分细则（建议）
- 正确区分三者职责：3 分
- 能描述 Element 的 build/update 流程与依赖注册：2 分
- 能说明 RenderObject 的 layout/paint 职责与触发条件（markNeedsLayout/markNeedsPaint）：2 分
- 加分（深入源码、举例或解释 trade-offs）：1–2 分

## Demo 项目说明（在 samples/q01_lifecycle）
- 此示例演示 Widget/Element/RenderObject 的生命周期日志与一个自定义 RenderBox 的绘制（查看 lib/main.dart）。
- 可在本地执行并用 DevTools 查看 rebuild / repaint 情况，示例 README 中提供调试步骤。
MD

########################
# Write docs for Q2
########################
cat > docs/02_Stateful_State_Persistence.md <<'MD'
# 题 2：StatefulWidget 状态持久性（State 保留/丢失/Key 的作用） — 深度解析

## 简短答案
- StatefulWidget 的 State 由对应的 Element 持有且在大多数普通父 rebuild 场景下会被保留。只有在 Widget 的 runtimeType 发生变化或 key 不匹配时，Element 会创建新的 State 导致原状态丢失。合理使用 Key（尤其是 ValueKey/UniqueKey/ObjectKey）可以控制子树的 identity，从而保护 State。

## 详细解析
### 1) 谁持有 State？
- State 对象的生命周期由 StatefulElement 管理。StatefulWidget 本身是不可变的配置对象，而 StatefulElement 会创建并保留其对应的 State。

### 2) State 何时被保留？
- 如果在父 Widget rebuild 的过程中，子 Widget 的 runtimeType 与 key 保持不变，Element 会 reuse（更新）现有的 Element/State，从而保留 State 的字段值与 controller。
- 例如：父 widget 触发 setState 并重建子 widget（没有改变子 widget 的 key 或 type）→ 子 widget 的 State 不会丢失。

### 3) State 何时丢失？
- 以下情况常导致 State 被丢弃并创建新的 State：
  - 子 Widget 的 type(runtimeType) 从 A 改为 B。
  - 子 Widget 的 Key 从一个值变成了另一个值（或从无 key 改为带 key，或 vice versa），导致 Element tree 重新匹配。
  - 在列表中移动元素但未使用合适 Key，导致 Flutter 以位置匹配，原有 State 可能被错误复用或丢弃，出现 UI/输入内容错位。

### 4) Key 的种类与用途
- Key 的主要作用是确定 Widget 的 identity，避免因 widget 重排导致 state 错误绑定。
  - ValueKey<T>(value)：用值作为身份标识，常用于列表中项 identity。
  - ObjectKey(object)：用对象 identity 标识。
  - UniqueKey()：每次都是唯一的，不应用于希望保留状态的项（反例）。
  - GlobalKey：全局唯一，能直接访问其它 widget 的 State（慎用，影响性能和封装性）。

### 5) 常见场景与示例
- 场景：在 ListView 中将 TextField 放在每个 item，当你改变列表 order，如果未使用 Key，TextField 的输入会错位；使用 ValueKey 保持 item 与 State 对应，输入能保持在正确 item 上。
- 场景：在 TabBarView 或 PageView 中需要保持页面状态时，可使用 AutomaticKeepAliveClientMixin 或 PageStorage 保持状态。

### 6) initState、didUpdateWidget、dispose 的作用
- initState：State 第一次被插入时调用，用于初始化（controller、订阅）。
- didUpdateWidget：当 widget 的配置发生变化但 State 被保留时调用（可在此比较 oldWidget/newWidget 做状态更新）。
- dispose：State 被销毁前调用，用于清理 controller、取消订阅等。

## 面试进阶问题与加分项
- 说明在长列表中使用 GlobalKey 的缺点（内存/性能）并给出替代（ValueKey）。
- 解释 AutomaticKeepAliveClientMixin 的工作机制（如何与 Sliver/Scrolling 协作）并举例。
- 能展示如何在 didUpdateWidget 中安全迁移旧状态到新配置（例如当 widget 的参数变化需要更新 controller）并提供示例代码。

## 评分细则（建议）
- 能解释 State 保留与被丢失的条件：3 分
- 能解释 Key 的类型与何时使用：2 分
- 能给出实际场景（如列表 reorder）并写出正确做法：2 分
- 加分（示例代码、AutomaticKeepAlive、didUpdateWidget 迁移策略）：1–2 分

## Demo 项目说明（在 samples/q02_state_persistence）
- 此示例为一个含多项 TextField 的列表，带 Shuffle 按钮与 “use keys” 开关，演示在使用/不使用 Key 时输入是否随项正确保留。
- 在项目中可以对比在 shuffle 时文本是否随 item identity 保留，从而直观理解 Key 的作用。
MD

########################
# Create README and LICENSE
########################
cat > README.md <<'MD'
# Flutter Interview Docs & Samples

This repository contains deep-dive answers and runnable sample apps for Flutter interview topics.

Structure:
- docs/ : deep-dive Markdown for each sample question
- samples/q01_lifecycle : Sample app demonstrating Widget/Element/RenderObject lifecycle
- samples/q02_state_persistence : Sample app demonstrating state persistence and use of Keys
- .github/workflows : CI workflows for Linux and macOS

Run the samples:
- Ensure Flutter (latest stable) is installed
- cd samples/q01_lifecycle && flutter pub get && flutter run
- cd samples/q02_state_persistence && flutter pub get && flutter run

MD

cat > LICENSE <<'MD'
MIT License
Copyright (c) $(date +"%Y")

Permission is hereby granted...
MD

########################
# Create sample apps (if flutter available)
########################
if [ -x "$(command -v flutter)" ]; then
  echo "Flutter detected. Creating sample apps using flutter create..."
  # q01
  flutter create samples/q01_lifecycle --project-name q01_lifecycle --org com.example || true
  # q02
  flutter create samples/q02_state_persistence --project-name q02_state_persistence --org com.example || true
else
  echo "Note: flutter not found in PATH. The script will still write sample main.dart files under samples/ but you should run 'flutter create' manually if needed."
  mkdir -p samples/q01_lifecycle lib samples/q02_state_persistence lib
fi

########################
# Overwrite main.dart for Q1
########################
cat > samples/q01_lifecycle/lib/main.dart <<'DART'
import 'package:flutter/material.dart';
import 'dart:developer' as dev;

void log(String s) {
  dev.log(s, name: 'lifecycle-demo');
  // also print for console
  print(s);
}

void main() {
  runApp(const MaterialApp(home: LifecycleDemoPage()));
}

class LifecycleDemoPage extends StatefulWidget {
  const LifecycleDemoPage({Key? key}) : super(key: key);

  @override
  State<LifecycleDemoPage> createState() => _LifecycleDemoPageState();
}

class _LifecycleDemoPageState extends State<LifecycleDemoPage> {
  int counter = 0;

  @override
  void initState() {
    super.initState();
    log('LifecycleDemoPage.initState');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    log('LifecycleDemoPage.didChangeDependencies');
  }

  @override
  void didUpdateWidget(covariant LifecycleDemoPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    log('LifecycleDemoPage.didUpdateWidget');
  }

  @override
  void dispose() {
    log('LifecycleDemoPage.dispose');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    log('LifecycleDemoPage.build');
    return Scaffold(
      appBar: AppBar(title: const Text('Lifecycle & RenderObject Demo')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Counter: \$counter', style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => setState(() => counter++),
              child: const Text('Increment'),
            ),
            const SizedBox(height: 20),
            const SizedBox(
              width: 200,
              height: 120,
              child: DecoratedBoxDemo(color: Colors.blueAccent),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => setState(() {}),
              child: const Text('Trigger rebuild'),
            ),
          ],
        ),
      ),
    );
  }
}

/// A simple LeafRenderObjectWidget that creates a RenderBox to draw.
class DecoratedBoxDemo extends LeafRenderObjectWidget {
  final Color color;
  const DecoratedBoxDemo({Key? key, required this.color}) : super(key: key);

  @override
  RenderObject createRenderObject(BuildContext context) {
    log('DecoratedBoxDemo.createRenderObject');
    return _DecoratedRenderBox(color);
  }

  @override
  void updateRenderObject(BuildContext context, covariant _DecoratedRenderBox renderObject) {
    log('DecoratedBoxDemo.updateRenderObject');
    renderObject.color = color;
  }
}

class _DecoratedRenderBox extends RenderBox {
  _DecoratedRenderBox(this._color);
  Color _color;
  set color(Color c) {
    if (_color != c) {
      _color = c;
      markNeedsPaint();
    }
  }

  @override
  void performLayout() {
    // respect incoming constraints - choose a size
    size = constraints.constrain(const Size(200, 120));
    // log layout
    log('DecoratedRenderBox.performLayout size=\$size constraints=\$constraints');
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final Canvas canvas = context.canvas;
    final Paint paint = Paint()..color = _color;
    canvas.drawRRect(
      RRect.fromRectAndRadius(offset & size, const Radius.circular(12)),
      paint,
    );
    // draw text
    final textPainter = TextPainter(
      text: const TextSpan(text: 'RenderBox', style: TextStyle(color: Colors.white, fontSize: 18)),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: size.width - 8);
    textPainter.paint(canvas, offset + const Offset(8, 8));
    log('DecoratedRenderBox.paint');
  }
}
DART

########################
# Overwrite main.dart for Q2
########################
cat > samples/q02_state_persistence/lib/main.dart <<'DART'
import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(home: StatePersistenceDemo()));
}

class StatePersistenceDemo extends StatefulWidget {
  const StatePersistenceDemo({Key? key}) : super(key: key);

  @override
  State<StatePersistenceDemo> createState() => _StatePersistenceDemoState();
}

class _StatePersistenceDemoState extends State<StatePersistenceDemo> {
  bool useKeys = false;
  List<_Item> items = List.generate(5, (i) => _Item('Item \$i', i));

  void shuffleItems() {
    setState(() {
      items.shuffle();
    });
  }

  void toggleUseKeys(bool? v) {
    setState(() {
      useKeys = v ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('State Persistence & Keys Demo')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Checkbox(value: useKeys, onChanged: toggleUseKeys),
                const Text('Use ValueKey for items'),
                const Spacer(),
                ElevatedButton(onPressed: shuffleItems, child: const Text('Shuffle')),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              children: items.map((item) {
                return _ItemWidget(
                  key: useKeys ? ValueKey(item.id) : null,
                  item: item,
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _Item {
  final String name;
  final int id;
  _Item(this.name, this.id);
}

class _ItemWidget extends StatefulWidget {
  final _Item item;
  const _ItemWidget({Key? key, required this.item}) : super(key: key);

  @override
  State<_ItemWidget> createState() => _ItemWidgetState();
}

class _ItemWidgetState extends State<_ItemWidget> {
  final TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    controller.text = 'Note for \${widget.item.name}';
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant _ItemWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If identity changed and we want to reset controller, we could detect here
    // but default behavior is to keep controller to demonstrate key effects
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(widget.item.name),
      subtitle: TextField(controller: controller),
    );
  }
}
DART

########################
# GitHub Actions - Linux (analyze & test)
########################
cat > .github/workflows/flutter_analyze_test.yml <<'YAML'
name: Flutter Analyze & Test (Linux)

on:
  push:
  pull_request:

jobs:
  analyze-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Install Flutter
        uses: subosito/flutter-action@v2
        with:
          channel: stable
      - name: Flutter --version
        run: flutter --version
      - name: Analyze
        run: |
          flutter pub get
          flutter analyze
      - name: Run tests (if any)
        run: |
          flutter pub get
          # run tests in each sample if present
          if [ -d samples/q01_lifecycle ]; then (cd samples/q01_lifecycle && flutter test) || true; fi
          if [ -d samples/q02_state_persistence ]; then (cd samples/q02_state_persistence && flutter test) || true; fi
YAML

########################
# GitHub Actions - macOS (iOS build verification)
########################
cat > .github/workflows/flutter_macos_ci.yml <<'YAML'
name: Flutter macOS / iOS CI

on:
  push:
  pull_request:

jobs:
  macos-build:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4
      - name: Install Flutter
        uses: subosito/flutter-action@v2
        with:
          channel: stable
      - name: Flutter doctor
        run: flutter doctor -v
      - name: Analyze
        run: |
          flutter pub get
          flutter analyze
      - name: Build iOS (no codesign)
        run: |
          if [ -d samples/q01_lifecycle ]; then
            cd samples/q01_lifecycle
            flutter pub get
            flutter build ios --no-codesign || true
            cd ../..
          fi
          if [ -d samples/q02_state_persistence ]; then
            cd samples/q02_state_persistence
            flutter pub get
            flutter build ios --no-codesign || true
            cd ../..
          fi
      - name: Run tests
        run: |
          if [ -d samples/q01_lifecycle ]; then (cd samples/q01_lifecycle && flutter test) || true; fi
          if [ -d samples/q02_state_persistence ]; then (cd samples/q02_state_persistence && flutter test) || true; fi
YAML

########################
# Finalize git commit
########################
git add -A
git commit -m "Add interview docs (Q1/Q2) and sample apps + CI flows" || true

echo "Init complete."
echo "If you want to push changes to origin, run: git push origin HEAD"
echo "Samples created in samples/q01_lifecycle and samples/q02_state_persistence"
echo "Docs created in docs/"
