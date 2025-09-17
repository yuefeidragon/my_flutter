#!/usr/bin/env bash
set -e
echo "=== Add batch Q18-Q27: docs + sample code files ==="
ROOT=$(pwd)
mkdir -p docs samples

# Q18: Image loading & decode optimization
cat > docs/18_image_decode.md <<'MD'
# Q18：图片加载与解码优化（ImageCache、ResizeImage、预解码、渐进加载）

标准答案要点：
- Flutter 在框架层有 ImageCache，尽量使用 ResizeImage/CacheWidth/CacheHeight 或者 decodeImageFromList 在合适大小进行解码以避免 OOM 和主线程卡顿。
- 使用 precacheImage 做预解码；使用 FadeInImage 或占位图做渐进加载；对网络图片用缓存策略（Etag/Cache-Control）避免重复下载。

深度解析：
- 说明 decode 流程（网络获取 -> bytes -> decode -> raster），以及为什么 decode 是 CPU/内存密集的。演示如何用 ResizeImage、ImageProvider.obtainKey + instantiateImageCodec 设置 targetWidth/targetHeight。
- 讨论 imageCache 的 sizeLimit、maxSizeBytes 配置与 eviction 策略，如何在低内存设备下调整。

加分项：
- 讨论 GPU upload 与 texture 大小对 rasterizer 的影响；讲解 use of compute/isolate for decoding大量图片的 tradeoff；示例如何在列表滚动时做 lazy decode。

评分细则（10分）：
- 流程与原理 4分；优化手段（Resize/precaching）3分；实践策略与边界条件 3分。
MD

mkdir -p samples/q18_image_opt/lib
cat > samples/q18_image_opt/lib/main.dart <<'DART'
import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: ImageOptDemo()));

class ImageOptDemo extends StatelessWidget {
  const ImageOptDemo({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    // Use ResizeImage to avoid decoding at full resolution
    final provider = ResizeImage(const NetworkImage('https://via.placeholder.com/2000'), width: 800);
    return Scaffold(
      appBar: AppBar(title: const Text('Image Decode Optimization')),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 12),
            Image(image: provider),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                // Example: precache image
                precacheImage(provider, context);
              },
              child: const Text('Precache'),
            ),
            const SizedBox(height: 8),
            const Text('Use ResizeImage / precacheImage to reduce runtime decode cost')
          ],
        ),
      ),
    );
  }
}
DART

# Q19: Custom GestureRecognizer & PointerEvent
cat > docs/19_gesture_recognizer.md <<'MD'
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
MD

mkdir -p samples/q19_gesture/lib
cat > samples/q19_gesture/lib/main.dart <<'DART'
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: GestureDemo()));

class _TapHoldRecognizer extends OneSequenceGestureRecognizer {
  // Very simple demo recognizer: treat a long press (>=500ms) as accepted
  Duration holdTime = const Duration(milliseconds: 500);
  bool _accepted = false;
  late int _primaryPointer;
  Timer? _timer;

  @override
  void addPointer(PointerEvent event) {
    startTrackingPointer(event.pointer);
    _primaryPointer = event.pointer;
    _timer = Timer(holdTime, () {
      if (!_accepted) {
        _accepted = true;
        resolve(GestureDisposition.accepted);
      }
    });
  }

  @override
  String get debugDescription => 'tapHold';

  @override
  void didStopTrackingLastPointer(int pointer) {}

  @override
  void handleEvent(PointerEvent event) {
    if (event is PointerUpEvent || event is PointerCancelEvent) {
      _timer?.cancel();
      if (!_accepted) resolve(GestureDisposition.rejected);
      stopTrackingPointer(event.pointer);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

class GestureDemo extends StatelessWidget {
  const GestureDemo({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Custom GestureRecognizer Demo')),
      body: Center(
        child: RawGestureDetector(
          gestures: {
            _TapHoldRecognizer: GestureRecognizerFactoryWithHandlers<_TapHoldRecognizer>(
              () => _TapHoldRecognizer(),
              (_TapHoldRecognizer instance) {},
            ),
          },
          child: Container(
            width: 200,
            height: 200,
            color: Colors.lightBlue,
            alignment: Alignment.center,
            child: const Text('Hold me for 500ms'),
          ),
        ),
      ),
    );
  }
}
DART

# Q20: CustomPainter vs RenderObject
cat > docs/20_painter_vs_render.md <<'MD'
# Q20：CustomPainter vs RenderObject 深入比较与选型建议

标准答案要点：
- CustomPainter 适用于局部绘制且与现有 Widget tree 一起工作（Painter 与 Picture），RenderObject 更底层适用于需要控件布局参与、复杂 hitTest、语义或与子 RenderObject 协同的场景。

深度解析：
- 介绍 CustomPainter 的 repaint/shouldRepaint 与如何用 RepaintBoundary 限制重绘；RenderObject 的优点是可以参与 layout 阶段并做精细控制。示例比较性能权衡：若需复杂布局/多子节点建议用 RenderObject，否则 CustomPainter 较快上手。

加分项：
- 说明如何把重复绘制逻辑缓存为 Picture 或 Layer，避免频繁重绘。

评分细则（10分）：
- 选型与原理 5分；实现差异与性能权衡 3分；缓存/优化策略 2分
MD

mkdir -p samples/q20_painter_vs_render/lib
cat > samples/q20_painter_vs_render/lib/main.dart <<'DART'
import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: Scaffold(body: Center(child: PainterVsRenderDemo()))));

class PainterVsRenderDemo extends StatelessWidget {
  const PainterVsRenderDemo({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(
          width: 200,
          height: 100,
          child: CustomPaint(
            painter: _MyPainter(),
          ),
        ),
        const SizedBox(height: 20),
        const Text('CustomPainter example above; use RenderObject for layout-aware painting'),
      ],
    );
  }
}

class _MyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = Colors.orange;
    canvas.drawRRect(Offset.zero & size, RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(12)), p);
    final tp = TextPainter(text: const TextSpan(text: 'Painter', style: TextStyle(color: Colors.white)), textDirection: TextDirection.ltr)..layout();
    tp.paint(canvas, const Offset(8,8));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
DART

# Q21: Sliver performance & lazy strategies
cat > docs/21_sliver.md <<'MD'
# Q21：Sliver 性能与懒加载策略（SliverList/SliverGrid/SliverPrototypeExtent）

标准答案要点：
- Sliver 提供延迟构建（sliverChildBuilderDelegate）和可回收机制；使用 SliverPrototypeExtentList 可以统一 item extent 优化测量；使用 KeepAlive 或 AutomaticKeepAliveClientMixin 保持页面状态。

深度解析：
- 说明 layout 流程（Sliver constraints/geometry），如何用 cachingExtent、addAutomaticKeepAlives、addRepaintBoundaries 调整性能，何时使用 addSemanticIndexes 防止语义树过大。

加分项：
- 讨论如何做动态 item 高度时的性能陷阱以及 sticky header / pinned appbar 的实现代价。

评分细则（10分）：
- Sliver 概念与关键 API 4分；懒加载/缓存策略 4分；实践建议 2分
MD

mkdir -p samples/q21_sliver/lib
cat > samples/q21_sliver/lib/main.dart <<'DART'
import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: Scaffold(body: SliverDemo())));

class SliverDemo extends StatelessWidget {
  const SliverDemo({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        const SliverAppBar(title: Text('Sliver Demo'), pinned: true, expandedHeight: 150),
        SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            return ListTile(title: Text('Item \$index'));
          }, childCount: 1000),
        ),
      ],
    );
  }
}
DART

# Q22: State restoration
cat > docs/22_restoration.md <<'MD'
# Q22：状态恢复（RestorationMixin、PageStorage、持久化恢复设计）

标准答案要点：
- RestorationMixin 与 restorationId 支持在系统杀死后恢复 UI 状态；PageStorage 用于简单滚动位置保存；对于复杂场景可结合 persisted storage（sqlite、shared_preferences）手工恢复。

深度解析：
- 说明 RestorationMixin 的 restoreState/restoreBucket 工作流，如何为自定义 State 保存/恢复值，注意 only supported on platforms with restoration support。

加分项：
- 讨论跨进程/跨版本的数据兼容性、以及如何设计恢复策略以避免安全/隐私问题。

评分细则（10分）：
- API 与流程理解 5分；实践与边界条件 3分；安全/数据兼容 2分
MD

mkdir -p samples/q22_restoration/lib
cat > samples/q22_restoration/lib/main.dart <<'DART'
import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: Scaffold(body: Center(child: Text('Restoration concept demo')))));
DART

# Q23: Offline-first sync & conflict resolution
cat > docs/23_offline_sync.md <<'MD'
# Q23：离线优先数据同步与冲突解决（操作日志/幂等/向量时钟/合并策略）

标准答案要点：
- 离线优先设计通常基于操作日志（oplog）、幂等操作与冲突合并（CRDT、OT、last-write/merge policies）。需要明确冲突优先级、合并逻辑与回滚/补偿策略。

深度解析：
- 讨论常见策略：客户端记录本地操作并在恢复网络时发到服务端；使用版本向量或时间戳解决冲突；如何保证幂等性与重放安全。举例说明冲突场景和合并策略选择依据（domain-driven）。

加分项：
- 说明如何在 UI 层做乐观更新并在合并失败时回滚，并提及安全/认证与数据一致性权衡。

评分细则（10分）：
- 架构与数据模型 4分；冲突解决策略 4分；实践注意事项 2分
MD

mkdir -p samples/q23_offline_sync/lib
cat > samples/q23_offline_sync/lib/main.dart <<'DART'
import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: Scaffold(body: Center(child: Text('Offline-first sync concept')))));
DART

# Q24: hot reload/restart/AOT/JIT differences
cat > docs/24_reload_aot.md <<'MD'
# Q24：hot reload / hot restart / AOT / JIT 差异与 release 问题定位

标准答案要点：
- hot reload: 仅替换 Dart 层代码，保留状态；hot restart: 重新启动 Dart VM，重置状态；AOT: release 模式下预编译为本地代码无调试信息，JIT: dev 模式可热 reload。
- release 模式的问题往往与未初始化 native 或 release-specific tree shaking、assert 被移除、不同行为（timing）相关。

深度解析：
- 给出实际排查流程：若在 release 下 bug 出现，优先在 profile/release 模式重现，检查使用到的 assert/debug-only code、platform channel 异常及 tree-shaken code。讨论 symbolication 与 crash reporting 的实践。

加分项：
- 讨论 minification/obfuscation 的影响、如何在 CI 做 AOT 测试覆盖。

评分细则（10分）：
- 区别理解 4分；release 下定位流程 4分；实践建议 2分
MD

mkdir -p samples/q24_reload/lib
cat > samples/q24_reload/lib/main.dart <<'DART'
import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: Scaffold(body: Center(child: Text('Hot reload vs restart concept')))));
DART

# Q25: Memory leak locating & fixes
cat > docs/25_memory_leak.md <<'MD'
# Q25：内存泄漏定位与修复（DevTools heap snapshot、Retaining Path）

标准答案要点：
- 使用 DevTools 的 Memory/Heap Snapshot 与 Retaining Path 定位泄漏对象，查找长时间持有引用（Stream subscriptions、Timers、Global caches、static collections、GlobalKey misuse）。
- 修复一般通过取消订阅、dispose controllers、使用 weak references 或减少全局状态及使用 scopes。

深度解析：
- 详细说明如何捕获 snapshot、比较 before/after、以及根据 retaining path 找到 root 引用链。列举常见泄漏原因并给出修复代码示例。

加分项：
- 讨论 Dart 的垃圾回收模型与 finalizer 的使用场景（慎用）。

评分细则（10分）：
- 工具使用与流程 4分；常见泄漏源识别 4分；修复策略 2分
MD

mkdir -p samples/q25_memory/lib
cat > samples/q25_memory/lib/main.dart <<'DART'
import 'dart:async';
import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: Scaffold(body: Center(child: Text('Memory leak concept demo')))));
DART

# Q26: PlatformChannel security & large file transfer
cat > docs/26_platform_security.md <<'MD'
# Q26：PlatformChannel 与本地接口安全（输入校验、签名/权限、传输大文件策略）

标准答案要点：
- Platform channel 的输入需做严格校验；对敏感操作需在 native 端进行权限/签名验证；大文件应通过临时文件路径传递而非直接在内存中传输。

深度解析：
- 讨论 native 权限流（Android runtime permission）、file lifecycle（temp dir）、以及如何做 integrity checks（hash 校验）。建议把 heavy work 放在 native/background thread 并返回文件路径或分片流（EventChannel/streaming）。

加分项：
- 讨论加密传输、签名验证与 native side 的 rate limiting、throttling 策略。

评分细则（10分）：
- 安全边界与校验 4分；大文件与性能策略 3分；实践建议 3分
MD

mkdir -p samples/q26_platform_security/lib
cat > samples/q26_platform_security/lib/main.dart <<'DART'
import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: Scaffold(body: Center(child: Text('Platform security concept')))));
DART

# Q27: Large-scale project architecture
cat > docs/27_architecture.md <<'MD'
# Q27：大规模项目架构（模块化/monorepo、版本管理、依赖隔离、渐进迁移）

标准答案要点：
- 模块化（feature modules）与 monorepo 各有利弊；monorepo 易于跨模块 refactor 与 CI，但需强大的工具链（bazel/lerna/gradle composite）。版本管理需采用语义化和清晰的发布策略。

深度解析：
- 讨论如何做依赖隔离（package boundaries、API contracts）、如何在 Flutter 中做插件/模块发布（pub packages / internal registries）、以及渐进迁移（adapter 层、feature flags、双写策略）。

加分项：
- 说明 CI 分层构建（affected tests/changed packages only）、模块契约测试与 API compatibility 检查的实现思路。

评分细则（10分）：
- 架构设计与 trade-offs 5分；工具链与发布策略 3分；渐进迁移计划 2分
MD

mkdir -p samples/q27_architecture/lib
cat > samples/q27_architecture/lib/main.dart <<'DART'
import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: Scaffold(body: Center(child: Text('Large-scale architecture concept')))));
DART

# Finalize commit
git add -A
git commit -m "Add batch Q18-Q27 docs and sample code snippets" || true

echo "Added docs/18-27 and samples/q18-q27 with sample main.dart files."
