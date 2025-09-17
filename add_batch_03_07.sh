#!/usr/bin/env bash
set -e
echo "=== Add batch Q03-Q07: docs + sample code files ==="
ROOT=$(pwd)
mkdir -p docs samples

# Q03: Performance tracing & jank demo (doc + sample main.dart)
cat > docs/03_performance_trace.md <<'MD'
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
MD

mkdir -p samples/q03_performance/lib
cat > samples/q03_performance/lib/main.dart <<'DART'
import 'dart:async';
import 'dart:math';
import 'dart:isolate';
import 'package:flutter/material.dart';

/// Q03: Performance demo code snippet (non-exhaustive)
/// This demo shows a toggle that either does heavy CPU work on main isolate
/// (causing jank) or offloads to a spawned isolate (smooth).
void main() => runApp(const MaterialApp(home: PerfDemo()));

class PerfDemo extends StatefulWidget {
  const PerfDemo({Key? key}) : super(key: key);
  @override
  State<PerfDemo> createState() => _PerfDemoState();
}

class _PerfDemoState extends State<PerfDemo> {
  bool useIsolate = false;
  int result = 0;

  void _doWorkOnMain() {
    // simulate heavy compute on UI thread (blocks)
    final int r = _heavyComputation(40);
    setState(() => result = r);
  }

  static int _heavyComputation(int n) {
    int sum = 0;
    for (int i = 0; i < pow(10, n).toInt(); i++) {
      sum += i % 7;
      if (i % 1000000 == 0) {
        // keep loop going
      }
    }
    return sum;
  }

  Future<void> _doWorkInIsolate() async {
    final p = ReceivePort();
    await Isolate.spawn(_isolateEntry, p.sendPort);
    final send = await p.first as SendPort;
    final rp = ReceivePort();
    send.send([40, rp.sendPort]);
    final res = await rp.first as int;
    setState(() => result = res);
    rp.close();
    p.close();
  }

  static void _isolateEntry(SendPort initialReply) {
    final rp = ReceivePort();
    initialReply.send(rp.sendPort);
    rp.listen((message) {
      final int n = message[0] as int;
      final SendPort reply = message[1] as SendPort;
      // perform computation (careful: this is illustrative and may still be huge)
      int s = 0;
      for (int i = 0; i < 10000000; i++) {
        s += i % (n + 1);
      }
      reply.send(s);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perf Demo')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text('Result: \$result'),
            const SizedBox(height: 12),
            SwitchListTile(
              title: const Text('Use Isolate'),
              value: useIsolate,
              onChanged: (v) => setState(() => useIsolate = v),
            ),
            ElevatedButton(
              onPressed: () {
                if (useIsolate) {
                  _doWorkInIsolate();
                } else {
                  _doWorkOnMain();
                }
              },
              child: const Text('Run heavy compute'),
            ),
            const SizedBox(height: 8),
            const Text('Use DevTools Performance -> Record to observe jank'),
          ],
        ),
      ),
    );
  }
}
DART

# Q04: Platform Channel camera interface (doc + sample main.dart)
cat > docs/04_platform_channel_camera.md <<'MD'
# 题 4：Platform Channel 接口设计：Dart 调用本地摄像头并返回缩放压缩后的 JPEG

## 标准答案要点
- MethodChannel 用于请求/响应（captureAndProcess），EventChannel 用于连续帧流（实时预览），FFI 适合高速本地库调用。
- 接口设计需关注：权限、线程、文件传输（路径优于大字节数组）、超时与错误映射、temp file 生命周期。

## 深度解析
（说明 MethodChannel JSON payload、如何在 Android 用 CameraX 在后台线程处理并返回临时文件路径；在 iOS 用 AVCapture＋CoreImage 处理）
## 加分项
- 讨论 libjpeg-turbo via FFI 的场景、Native->Dart 归档方式（path vs bytes）、对大文件使用 platform-specific streams。
## 评分细则
- 接口设计 3 分；Android/iOS 实现要点 4 分；性能/安全/错误处理 3 分
MD

mkdir -p samples/q04_platform_channel_camera/lib
cat > samples/q04_platform_channel_camera/lib/main.dart <<'DART'
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Q04: Dart side MethodChannel example for captureAndProcess
const MethodChannel _channel = MethodChannel('com.example.camera');

void main() => runApp(const MaterialApp(home: CameraExample()));

class CameraExample extends StatefulWidget {
  const CameraExample({Key? key}) : super(key: key);
  @override
  State<CameraExample> createState() => _CameraExampleState();
}

class _CameraExampleState extends State<CameraExample> {
  String _status = 'idle';
  String? _lastPath;

  Future<void> _capture() async {
    setState(() => _status = 'capturing...');
    try {
      final Map<dynamic, dynamic> res = await _channel.invokeMethod('captureAndProcess', {
        'width': 800,
        'height': 600,
        'quality': 80,
      });
      // Expect native returns {'path': '/tmp/xx.jpg'}
      final String path = res['path'] as String;
      setState(() {
        _status = 'done';
        _lastPath = path;
      });
    } on PlatformException catch (e) {
      setState(() => _status = 'error: \${e.message}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Platform Channel Camera Demo')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Status: \$_status'),
            const SizedBox(height: 8),
            ElevatedButton(onPressed: _capture, child: const Text('Capture')),
            if (_lastPath != null) Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Last path: \$_lastPath'),
            ),
            const SizedBox(height: 16),
            const Text('Native side should return a temp file path; Dart should not transfer big bytes')
          ],
        ),
      ),
    );
  }
}
DART

# Q05: CI design sample - provide Flutter code & a simple widget test
cat > docs/05_ci_design.md <<'MD'
# 题 5：CI 流程设计（静态检查、单元/Widget 测试、iOS 无签名构建、Simulator 上的 integration_test）

## 标准答案要点
- Pipeline: checkout -> pub get -> analyze -> test -> build ios --no-codesign (macos) -> (optional) run integration_test on simulator.
- Certificates & profiles: use secrets/fastlane match / App Store Connect API keys; store secrets in CI provider.
## 深度解析
（包括 xcrun simctl 启动模拟器、如何解密证书、如何安全管理 secrets、如何保存 artifacts、如何对热更做回滚策略）
## 加分项
- 提到 use of GitHub Actions matrix for multiple flutter versions/architectures；如何在 CI 中运行 flutter test for each sample project.
## 评分细则
- Pipeline 完整性 4 分；macOS/simulator 细节 3 分；证书/安全运维 3 分
MD

mkdir -p samples/q05_ci_design/lib test
cat > samples/q05_ci_design/lib/main.dart <<'DART'
import 'package:flutter/material.dart';
void main() => runApp(const MaterialApp(home: Scaffold(body: Center(child: Text('CI Demo')))));
DART

cat > samples/q05_ci_design/test/widget_test.dart <<'DART'
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:q05_ci_design/main.dart' as app;

void main() {
  testWidgets('CI demo smoke test', (WidgetTester tester) async {
    app.main();
    await tester.pumpAndSettle();
    expect(find.text('CI Demo'), findsOneWidget);
  });
}
DART

# Q06: Advanced RenderBox example (doc + sample)
cat > docs/06_advanced_renderbox.md <<'MD'
# 题 6：实现自定义 RenderBox（高效绘制、TextPainter 缓存、hitTest、semantics）

## 要点
- 在 performLayout 使用 constraints.constrain
- 在 paint 中重用 TextPainter，不在 paint 中 new TextPainter 每帧
- 实现 hitTestSelf/hitTestChildren 与 describeSemanticsConfiguration
- 使用 markNeedsLayout/markNeedsPaint 的时机
## 加分项
- 说明如何使用 layer cache/raster cache；讨论在复杂子树使用 RepaintBoundary 的权衡。
MD

mkdir -p samples/q06_renderbox_advanced/lib
cat > samples/q06_renderbox_advanced/lib/main.dart <<'DART'
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

void main() => runApp(const MaterialApp(home: Scaffold(body: Center(child: AdvancedBoxDemo()))));

class AdvancedBoxDemo extends LeafRenderObjectWidget {
  const AdvancedBoxDemo({Key? key}) : super(key: key);
  @override
  RenderObject createRenderObject(BuildContext context) => _AdvancedRenderBox();
}

class _AdvancedRenderBox extends RenderBox {
  final TextPainter _tp = TextPainter(textDirection: TextDirection.ltr);
  Color _color = Colors.teal;

  @override
  void performLayout() {
    size = constraints.constrain(const Size(200, 80));
  }

  void _layoutText() {
    _tp.text = const TextSpan(text: 'AdvancedRenderBox', style: TextStyle(color: Colors.white, fontSize: 16));
    _tp.layout(maxWidth: size.width - 8);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    final Canvas canvas = context.canvas;
    final Paint p = Paint()..color = _color;
    canvas.drawRRect(offset & size, RRect.fromRectAndRadius(offset & size, const Radius.circular(8)), p);
    _layoutText();
    _tp.paint(canvas, offset + const Offset(8, 8));
  }

  @override
  bool hitTestSelf(Offset position) => (position.dx >= 0 && position.dy >= 0 && position.dx <= size.width && position.dy <= size.height);
}
DART

# Q07: Advanced keys & KeepAlive demo
cat > docs/07_keys_keepalive.md <<'MD'
# 题 7：Key 与 KeepAlive 的进阶用法（列表重排、PageView 保持、AutomaticKeepAliveClientMixin）

## 要点
- Key 决定 identity，ValueKey/ObjectKey/GlobalKey/UniqueKey 的差异
- AutomaticKeepAliveClientMixin 与 PageStorage 的适用场景（Tab 页面/懒加载）及实现方式
## 加分项
- 讨论 GlobalKey 拥有 State 引用的场景与代价；如何避免内存/性能问题
MD

mkdir -p samples/q07_keys_keepalive/lib
cat > samples/q07_keys_keepalive/lib/main.dart <<'DART'
import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: KeysKeepAliveDemo()));

class KeysKeepAliveDemo extends StatefulWidget {
  const KeysKeepAliveDemo({Key? key}) : super(key: key);
  @override
  State<KeysKeepAliveDemo> createState() => _KeysKeepAliveDemoState();
}

class _KeysKeepAliveDemoState extends State<KeysKeepAliveDemo> {
  bool useKeys = true;
  List<int> items = List.generate(6, (i) => i);

  void shuffleItems() {
    setState(() => items.shuffle());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Keys & KeepAlive Demo')),
      body: Column(
        children: [
          SwitchListTile(
            title: const Text('Use ValueKey'),
            value: useKeys,
            onChanged: (v) => setState(() => useKeys = v),
          ),
          ElevatedButton(onPressed: shuffleItems, child: const Text('Shuffle')),
          Expanded(
            child: ListView(
              children: items.map((id) => _TileWidget(key: useKeys ? ValueKey(id) : null, id: id)).toList(),
            ),
          )
        ],
      ),
    );
  }
}

class _TileWidget extends StatefulWidget {
  final int id;
  const _TileWidget({Key? key, required this.id}) : super(key: key);
  @override
  State<_TileWidget> createState() => _TileWidgetState();
}

class _TileWidgetState extends State<_TileWidget> with AutomaticKeepAliveClientMixin {
  String text = '';
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    text = 'note for \${widget.id}';
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return ListTile(
      title: Text('Item \${widget.id}'),
      subtitle: TextField(controller: TextEditingController(text: text)),
    );
  }
}
DART

# git add & commit
git add -A
git commit -m "Add batch Q03-Q07 docs and sample Flutter code snippets" || true

echo "Added docs/03-07 and samples/q03-q07 with sample main.dart files."
echo "Run 'git push origin HEAD' to push changes (use PAT or SSH as configured)."
