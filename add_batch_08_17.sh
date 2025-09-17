#!/usr/bin/env bash
set -e
echo "=== Add batch Q08-Q17: docs + sample code files ==="
ROOT=$(pwd)
mkdir -p docs samples

########################
# Q08: InheritedWidget / Provider 原理与优化（docs + sample）
########################
cat > docs/08_provider_inherited.md <<'MD'
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
MD

mkdir -p samples/q08_provider_inherited/lib
cat > samples/q08_provider_inherited/lib/main.dart <<'DART'
import 'package:flutter/material.dart';

// 简单的 InheritedWidget 示例（没有依赖外部 package）
void main() => runApp(const MyApp());

class CounterModel extends InheritedWidget {
  final int count;
  final Widget child;
  const CounterModel({required this.count, required this.child}) : super(child: child);

  static CounterModel? of(BuildContext context) => context.dependOnInheritedWidgetOfExactType<CounterModel>();

  @override
  bool updateShouldNotify(covariant CounterModel oldWidget) => oldWidget.count != count;
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);
  @override State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _c = 0;
  @override
  Widget build(BuildContext context) {
    return CounterModel(
      count: _c,
      child: MaterialApp(
        home: Scaffold(
          appBar: AppBar(title: const Text('InheritedWidget Demo')),
          body: Column(
            children: [
              const SizedBox(height: 20),
              Builder(builder: (context) {
                final model = CounterModel.of(context);
                return Text('Count: \${model?.count}', style: const TextStyle(fontSize: 24));
              }),
              ElevatedButton(onPressed: () => setState(() => _c++), child: const Text('Increment')),
            ],
          ),
        ),
      ),
    );
  }
}
DART

########################
# Q09: Bloc/Cubit 模式与测试（docs + sample）
########################
cat > docs/09_bloc_cubit.md <<'MD'
# Q09：Bloc/Cubit 模式本质、拆分与可测试性（深度解析）

标准答案要点：
- Bloc 是事件驱动的状态机：事件 -> 处理 -> 发出新状态；保持单向数据流和可测试性。Cubit 为轻量级状态容器，直接 emit state。

深度解析：
- 说明如何拆分模块（feature-based blocs），如何写单元测试（把事件发送到 bloc，验证输出 states），以及如何解耦副作用（使用 repository/抽象接口和 mock）。
- 性能与内存：避免在 bloc 中直接持有 BuildContext 或 UI 对象，清理订阅并在 close 时释放资源。

加分项：
- 写出一个简单的 bloc 单元测试示例（使用 StreamQueue 或 expectLater + emitsInOrder）并说明 mock repository 的策略。

评分细则（10分）：
- 模式理解 3分；测试方法 4分；架构拆分与依赖注入 3分。
MD

mkdir -p samples/q09_bloc_cubit/lib
cat > samples/q09_bloc_cubit/lib/main.dart <<'DART'
import 'dart:async';
import 'package:flutter/material.dart';

/// Q09: 简单的手写 Bloc（无依赖包），用于教学与测试
void main() => runApp(const MaterialApp(home: BlocDemo()));

class CounterBloc {
  int _count = 0;
  final _controller = StreamController<int>.broadcast();
  Stream<int> get stream => _controller.stream;
  void increment() {
    _count++;
    _controller.add(_count);
  }
  void dispose() => _controller.close();
}

class BlocDemo extends StatefulWidget {
  const BlocDemo({Key? key}) : super(key: key);
  @override State<BlocDemo> createState() => _BlocDemoState();
}

class _BlocDemoState extends State<BlocDemo> {
  final bloc = CounterBloc();
  @override
  void dispose() { bloc.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Simple Bloc Demo')),
      body: StreamBuilder<int>(
        stream: bloc.stream,
        initialData: 0,
        builder: (context, snapshot) {
          return Center(child: Text('Count: \${snapshot.data}', style: const TextStyle(fontSize:24)));
        },
      ),
      floatingActionButton: FloatingActionButton(onPressed: bloc.increment, child: const Icon(Icons.add)),
    );
  }
}
DART

########################
# Q10: Riverpod 原理与高级用法（docs + sample）
########################
cat > docs/10_riverpod.md <<'MD'
# Q10：Riverpod 原理（ProviderContainer、ScopedProviders）与高级用法（family、autoDispose）

标准答案要点：
- Riverpod 将 provider 的生命周期与读取解耦，可以通过 ProviderContainer 在非 Widget 环境中读取 provider；family 用于参数化 provider，autoDispose 自动回收资源。

深度解析：
- 说明与 Provider 的区别（context-free、测试友好、依赖注入的可组合性），并示例如何在测试中用 ProviderContainer 做隔离测试。

加分项：
- 说明监听 provider 变化的高阶场景（override、refresh）和 performance tips（避免不必要的 provider 链）。
评分细则（10分）：
- 原理与对比 4分；family/autoDispose 实战 3分；测试与容器用法 3分。
MD

mkdir -p samples/q10_riverpod/lib
cat > samples/q10_riverpod/lib/main.dart <<'DART'
import 'package:flutter/material.dart';

/// Q10: Riverpod 概念示例（此处为概念性示例，不依赖 riverpod 包）
/// 真实项目请使用 riverpod package；此处展示 provider 参数化与生命周期思想。
void main() => runApp(const MaterialApp(home: Scaffold(body: Center(child: Text('Riverpod concept demo')))));
DART

########################
# Q11: Navigator 2.0 / RouterDelegate 深挖（docs + sample）
########################
cat > docs/11_navigator2.md <<'MD'
# Q11：Navigator 2.0 / RouterDelegate / RouteInformationParser 深挖

标准答案要点：
- Navigator 2.0 提供声明式路由，通过 RouterDelegate 管理导航栈并响应外部 URL（RouteInformationParser 负责解析/恢复）。

深度解析：
- 解释 RouterDelegate 的 build/notifyListeners、currentConfiguration；说明如何实现 deep-link、后退处理及页面状态恢复（Restoration）。
加分项：
- 举例说明在大型应用中如何把 RouterDelegate 与 app state（auth、onboarding）解耦；如何做 URL-to-state 双向同步。

评分细则（10分）：核心概念 4分；实现要点 4分；扩展（deep link/restore）2分
MD

mkdir -p samples/q11_navigator2/lib
cat > samples/q11_navigator2/lib/main.dart <<'DART'
import 'package:flutter/material.dart';

// Q11: Minimal Navigator 2.0 skeleton (concept)
// For full apps, implement RouterDelegate/RouteInformationParser classes.
void main() => runApp(const MaterialApp(home: Scaffold(body: Center(child: Text('Navigator 2.0 skeleton')))));
DART

########################
# Q12: Flutter 动画深挖（docs + sample）
########################
cat > docs/12_animation.md <<'MD'
# Q12：Flutter 动画深入（Implicit vs Explicit、性能与复用）

标准答案要点：
- Implicit animations（AnimatedContainer 等）适合简单属性动画；Explicit（AnimationController + Tween）适合复杂、可控动画。
- 注意 lifecycle（dispose controller），复用 controller 与 AnimationController 的 vsync 使用（TickerProvider）以节省资源。

加分项：
- 如何使用 AnimationController.forward/reverse、使用 CurvedAnimation 复用 easing、避免在 build 中创建 controller。
评分细则（10分）：分类理解 3分；API 使用与生命周期 4分；性能与复用 3分
MD

mkdir -p samples/q12_animation/lib
cat > samples/q12_animation/lib/main.dart <<'DART'
import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: AnimationDemo()));

class AnimationDemo extends StatefulWidget {
  const AnimationDemo({Key? key}) : super(key: key);
  @override State<AnimationDemo> createState() => _AnimationDemoState();
}

class _AnimationDemoState extends State<AnimationDemo> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _anim;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds:1));
    _anim = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
  }
  @override void dispose() { _controller.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Animation Demo')),
      body: Center(
        child: FadeTransition(opacity: _anim, child: ElevatedButton(onPressed: ()=>_controller.forward(from:0), child: const Text('Animate'))),
      ),
    );
  }
}
DART

########################
# Q13: 网络层设计与缓存策略（docs + sample）
########################
cat > docs/13_network_cache.md <<'MD'
# Q13：网络层设计与缓存策略（拦截器、重试、离线缓存）

标准答案要点：
- 拦截器用于统一处理认证/重试；离线缓存可用 sqflite、hive、或 HTTP cache（Etag/Cache-Control）。
- 设计要考虑幂等性、重试策略（指数退避）、并发请求合并（request deduplication）。

加分项：
- 讨论缓存失效策略（LRU、基于时间/版本）、冲突合并（last-write/merge/CRDT）、以及安全（加密存储 token）。
评分细则（10分）：设计完整性 4分；缓存实现细节 3分；安全/冲突策略 3分
MD

mkdir -p samples/q13_network_cache/lib
cat > samples/q13_network_cache/lib/main.dart <<'DART'
import 'package:flutter/material.dart';

/// Q13: Network concept demo - pseudo code for retry/backoff and cache idea
void main() => runApp(const MaterialApp(home: Scaffold(body: Center(child: Text('Network & Cache concept')))));
DART

########################
# Q14: Tests 深入（docs + sample）
########################
cat > docs/14_tests.md <<'MD'
# Q14：Tests 深入：Widget/Integration/Golden tests 与 Mock PlatformChannel

标准答案要点：
- Widget tests 模拟 Widget 层，integration tests 在真实 engine 上运行；golden tests 用于 UI 回归。
- Mock PlatformChannel：在测试中用 MethodChannel.setMockMethodCallHandler 模拟 native 返回。

加分项：
- CI 集成时使用 headless device / simulator、管理 golden baseline 与差异阈值、并行化测试策略。
评分细则（10分）：测试分类 3分；mock 与 golden 细节 4分；CI 集成建议 3分
MD

mkdir -p samples/q14_tests/lib
cat > samples/q14_tests/lib/main.dart <<'DART'
import 'package:flutter/material.dart';
void main() => runApp(const MaterialApp(home: Scaffold(body: Center(child: Text('Tests demo')))));
DART

########################
# Q15: Dart FFI 深入（docs + sample）
########################
cat > docs/15_ffi.md <<'MD'
# Q15：Dart FFI 深入：内存管理、回调、struct 对齐与跨平台构建

标准答案要点：
- FFI 通过 C ABI 调用本地函数，数据必须 marshal（Bytes / Utf8 / malloc），注意 free；回调需用 NativePort 或 NativeCallable；struct 对齐需与 C 头文件一致。
- 跨平台构建要考虑各平台的编译链与 ABI（arm64/x86_64），并用 CI 做多平台 binary 构建。

加分项：
- 讨论 panic/unwind、线程模型（不要在 Dart isolate 里直接访问非线程安全代码）、以及如何在 Dart 层封装安全接口。
评分细则（10分）：基础概念 4分；内存与回调细节 4分；跨平台构建 2分
MD

mkdir -p samples/q15_ffi/lib
cat > samples/q15_ffi/lib/main.dart <<'DART'
import 'package:flutter/material.dart';

/// Q15: FFI conceptual sample (no real native linked code here)
void main() => runApp(const MaterialApp(home: Scaffold(body: Center(child: Text('FFI concept demo')))));
DART

########################
# Q16: 插件封装与兼容性（docs + sample）
########################
cat > docs/16_plugin_wrapping.md <<'MD'
# Q16：插件封装与版本兼容性：封装复杂 Native SDK 的策略

标准答案要点：
- 在 native 端封装稳定、简单的接口；Dart 端做适配并提供高层 API；关注线程、错误映射与资源释放。
- 兼容策略：feature detection、fallback implementation、semantic versioning 和严格的 breaking change policy。

加分项：
- 示范如何在 Dart 端做版本适配层、自动回退及灰度发布策略（feature flags + runtime checks）。
评分细则（10分）：封装设计 4分；兼容与回退策略 4分；测试/文档 2分
MD

mkdir -p samples/q16_plugin_wrapping/lib
cat > samples/q16_plugin_wrapping/lib/main.dart <<'DART'
import 'package:flutter/material.dart';
void main() => runApp(const MaterialApp(home: Scaffold(body: Center(child: Text('Plugin wrapping concept')))));
DART

########################
# Q17: i18n 与 a11y（docs + sample）
########################
cat > docs/17_i18n_a11y.md <<'MD'
# Q17：国际化 (i18n) 与无障碍 (a11y)：实现策略与测试

标准答案要点：
- i18n: 使用 ARB/intl、按 locale 提供翻译、格式化日期/数字、支持 RTL 布局；使用 flutter_localizations 与 gen_l10n 工具链。
- a11y: 提供语义（Semantics）、正确的 contrast、Focus order、可访问触控目标大小与测试（TalkBack/VoiceOver）。

加分项：
- 说明如何做语言回退、动态切换、以及自动化无障碍扫描与可访问性检查。
评分细则（10分）：i18n 实践 4分；a11y 实践 4分；测试/工具 2分
MD

mkdir -p samples/q17_i18n_a11y/lib
cat > samples/q17_i18n_a11y/lib/main.dart <<'DART'
import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: Scaffold(body: Center(child: Text('i18n & a11y concept demo')))));
DART

# Finalize commit
git add -A
git commit -m "Add batch Q08-Q17 docs and sample code snippets" || true

echo "Added docs/08-17 and samples/q08-q17 with sample main.dart files."
echo "Run 'git push origin HEAD' to push changes (use PAT or SSH as configured)."
