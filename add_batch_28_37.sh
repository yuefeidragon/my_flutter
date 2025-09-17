#!/usr/bin/env bash
set -e
echo "=== Add batch Q28-Q37: docs + sample code files ==="
ROOT=$(pwd)
mkdir -p docs samples

# Q28: App size optimization (tree-shaking, split AOT, asset trimming)
cat > docs/28_app_size_optimization.md <<'MD'
# Q28：应用体积优化（Tree-shaking、AOT 拆分、资源裁剪）

标准答案要点：
- 使用 Flutter 的 release/AOT 构建并启用 tree-shaking，移除无用代码与未使用资源。
- 使用 split-debug-info、--split-per-abi、按需资源/asset 压缩与按分包加载减小用户下载大小。

深度解析：
- 说明 Dart/Flutter 的 tree-shaking 原理、如何使用 flutter build appbundle / flutter build apk --split-per-abi，如何配置 build flavors 与按需资源包（on-demand modules）。
- 讨论图片压缩、字体子集化、移除调试信息、剔除未用本地化和资源等实践。

加分项：
- 介绍使用 deferred components（Android split install）与 Play Feature Delivery 做按需模块加载的思路。

评分细则（10分）：
- 原理与命令 4 分；资源裁剪与分包策略 4 分；加分项/工具链 2 分
MD

mkdir -p samples/q28_app_size/lib
cat > samples/q28_app_size/lib/main.dart <<'DART'
import 'package:flutter/material.dart';
void main() => runApp(const MaterialApp(home: Scaffold(body: Center(child: Text('App size optimization notes')))));
DART

# Q29: Obfuscation & symbolication (proguard, split-debug-info)
cat > docs/29_obfuscation_symbolication.md <<'MD'
# Q29：代码混淆与崩溃符号化（Obfuscation & Symbolication）

标准答案要点：
- 使用 --obfuscate 与 --split-debug-info 进行 Dart 层混淆并保留符号信息以便后来符号化崩溃堆栈。
- Android 可配合 ProGuard/R8；iOS 使用 dSYM 上传以便符号化。

深度解析：
- 说明如何在 CI 中保存 split-debug-info 的符号文件并上传到错误采集服务（Sentry/Crashlytics），以及 release 策略与混淆带来的调试权衡。

加分项：
- 讨论对第三方插件、本地库的符号化与混淆注意事项。

评分细则（10分）：
- 工具与流程 5 分；CI/错误上报集成 3 分；实践风险与权衡 2 分
MD

mkdir -p samples/q29_obfuscation/lib
cat > samples/q29_obfuscation/lib/main.dart <<'DART'
import 'package:flutter/material.dart';
void main() => runApp(const MaterialApp(home: Scaffold(body: Center(child: Text('Obfuscation & symbolication notes')))));
DART

# Q30: Background execution & isolates vs native background tasks
cat > docs/30_background_isolates.md <<'MD'
# Q30：后台执行：Isolate 与原生后台任务的选型与实现

标准答案要点：
- Dart isolate 适合 CPU 密集或并发任务但不能持久运行在 app 被系统杀死后；需要长期后台任务应使用原生后台 API（Android WorkManager、iOS Background Tasks/VoIP）并通过 PlatformChannel 协调。

深度解析：
- 说明如何在 Flutter 中创建 isolate、使用 compute、与 native 后台服务交互（传 file path / minimal payload），以及如何做任务调度与电量/网络条件约束。

加分项：
- 提供具体 Android WorkManager 与 iOS BGProcessing 实现要点与与 Flutter 的集成方案。

评分细则（10分）：
- 选型判断 4 分；实现细节 4 分；边界条件与权衡 2 分
MD

mkdir -p samples/q30_background/lib
cat > samples/q30_background/lib/main.dart <<'DART'
import 'dart:async';
import 'dart:isolate';
import 'package:flutter/material.dart';

void main() => runApp(const MaterialApp(home: Scaffold(body: Center(child: Text('Background tasks concept')))));

/// 示意：启动一个短生命周期的 isolate
Future<void> spawnExample() async {
  final p = ReceivePort();
  await Isolate.spawn(_entry, p.sendPort);
  final send = await p.first as SendPort;
  final rp = ReceivePort();
  send.send(['work', rp.sendPort]);
  await rp.first;
}

void _entry(SendPort sp) {
  final rp = ReceivePort();
  sp.send(rp.sendPort);
  rp.listen((msg) {
    // do work...
    final SendPort reply = msg[1] as SendPort;
    reply.send(true);
  });
}
DART

# Q31: Flutter engine embedding & PlatformViews
cat > docs/31_engine_platform_views.md <<'MD'
# Q31：Flutter 引擎嵌入与 PlatformView（嵌套原生视图）实现要点

标准答案要点：
- PlatformView 用于嵌入复杂原生控件（地图、广告、WebView），但会带来性能/合成层次的开销（texture vs hybrid composition）。

深度解析：
- 讨论 Android 上的 hybrid composition 与 TextureView 方案、iOS 上的 UIView-hosting，注意滚动/手势传递与 z-order 问题、性能代价与替代方案（将逻辑移至 Dart 端或用自绘实现）。

加分项：
- 说明如何做异步初始化、复用 native view 与避免频繁创建销毁的策略。

评分细则（10分）：
- 概念与实现差异 4 分；性能与手势问题 4 分；最佳实践 2 分
MD

mkdir -p samples/q31_platform_views/lib
cat > samples/q31_platform_views/lib/main.dart <<'DART'
import 'package:flutter/material.dart';
void main() => runApp(const MaterialApp(home: Scaffold(body: Center(child: Text('PlatformView concept')))));
DART

# Q32: Shader & custom GPU rendering (SkSL, FragmentProgram)
cat > docs/32_shader_gpu.md <<'MD'
# Q32：Shader 与自定义 GPU 渲染（SkSL / FragmentProgram）

标准答案要点：
- 使用 FragmentProgram（dart:ui 提供）或自定义 SkSL shader 可做高性能 visual effect；要注意 shader 的兼容性与 size、以及在不同设备上的性能。

深度解析：
- 说明如何编译 GLSL/SkSL 到可嵌入的 binary，如何在 Flutter 中 load 和使用 shader，如何避免在每帧重新上传 large uniform 数据。

加分项：
- 提及 Web 与不同 GPU 架构下的行为差异与回退策略。

评分细则（10分）：
- 概念与 API 4 分；性能与兼容策略 4 分；实践示例 2 分
MD

mkdir -p samples/q32_shader/lib
cat > samples/q32_shader/lib/main.dart <<'DART'
import 'package:flutter/material.dart';
void main() => runApp(const MaterialApp(home: Scaffold(body: Center(child: Text('Shader concept demo')))));
DART

# Q33: Hotfix strategies (code push / dynamic features)
cat > docs/33_hotfix.md <<'MD'
# Q33：热修复策略（Code push / 动态功能发布）

标准答案要点：
- Flutter 本身不推荐运行时代码替换（安全与平台限制），可用远端配置、JS/WasM 沙箱、或利用动态资源和服务器控制的 feature flags 实现快速回滚与灰度。

深度解析：
- 讨论热修复工具（风险：安全、审计、平台政策）、灰度发布与 feature flag 的实现（基于用户、版本、百分比），以及静态资源/布局远程调整的设计。

加分项：
- 结合 A/B 测试、metric-driven 回滚与发布策略的示例。

评分细则（10分）：
- 风险/合规判断 4 分；替代方案（flags/remote config）4 分；实践建议 2 分
MD

mkdir -p samples/q33_hotfix/lib
cat > samples/q33_hotfix/lib/main.dart <<'DART'
import 'package:flutter/material.dart';
void main() => runApp(const MaterialApp(home: Scaffold(body: Center(child: Text('Hotfix / feature flag concept')))));
DART

# Q34: Dependency injection & service locator
cat > docs/34_di_service_locator.md <<'MD'
# Q34：依赖注入与 Service Locator（GetIt / Provider / constructor injection）

标准答案要点：
- 推荐 constructor/DI container（GetIt、riverpod）与显式依赖传递提高可测性；Service Locator 简化使用但会降低可追踪性与测试性。

深度解析：
- 说明生命周期管理（singletons vs scoped），测试替换（overrides / mocks）与依赖循环回避策略。

加分项：
- 示例如何在模块化代码中按 feature scope 注入依赖并做自动化契约测试。

评分细则（10分）：
- 模式比较 4 分；生命周期与测试 4 分；实践示例 2 分
MD

mkdir -p samples/q34_di/lib
cat > samples/q34_di/lib/main.dart <<'DART'
import 'package:flutter/material.dart';

/// 简单演示 Service Locator 风格（仅为示例）
class ServiceA {
  String greet() => 'hello from ServiceA';
}

final _globalA = ServiceA();

void main() => runApp(MaterialApp(home: Scaffold(body: Center(child: Text(_globalA.greet())))));
DART

# Q35: Observability & logging/metrics/crash reporting
cat > docs/35_observability.md <<'MD'
# Q35：可观测性：结构化日志、指标与崩溃上报

标准答案要点：
- 使用结构化日志（JSON）、集中式日志系统、指标（Prometheus-style / statsd）、以及崩溃上报（Sentry/Crashlytics）实现可观测性。

深度解析：
- 说明客户端采集策略（采样、上报频率、离线缓存）、隐私合规（PII 去除）、以及在 CI/Release 环境下如何集成实时告警和回归分析。

加分项：
- 讨论指标标签设计、trace context（分布式追踪）与性能相关的自定义度量。

评分细则（10分）：
- 设计与采集策略 4 分；隐私/压缩/上报 3 分；告警与回归分析 3 分
MD

mkdir -p samples/q35_observability/lib
cat > samples/q35_observability/lib/main.dart <<'DART'
import 'package:flutter/material.dart';
void main() => runApp(const MaterialApp(home: Scaffold(body: Center(child: Text('Observability notes')))));
DART

# Q36: Build flavors & environment configuration
cat > docs/36_build_flavors.md <<'MD'
# Q36：构建风味（flavors）与环境配置管理

标准答案要点：
- 使用 flavors（Android productFlavors / iOS schemes）和 Dart 环境变量或编译时常量管理不同环境（dev/staging/prod），在 CI 中按矩阵构建并生成不同配置包。

深度解析：
- 说明如何在 flutter build 时传入 --flavor，如何在 native gradle/xcodeproj 中维护不同资源和 API Key，如何在 CI 中安全注入 secrets。

加分项：
- 提供多环境证书管理、自动化构建与部署流水线思路。

评分细则（10分）：
- Flavors 配置 4 分；CI 集成与 secrets 管理 4 分；实践示例 2 分
MD

mkdir -p samples/q36_flavors/lib
cat > samples/q36_flavors/lib/main.dart <<'DART'
import 'package:flutter/material.dart';
void main() => runApp(const MaterialApp(home: Scaffold(body: Center(child: Text('Build flavors concept')))));
DART

# Q37: Security best practices (secure storage, TLS, input validation)
cat > docs/37_security_best_practices.md <<'MD'
# Q37：安全最佳实践（安全存储、TLS、输入校验）

标准答案要点：
- 使用平台安全存储（Keychain/Keystore / flutter_secure_storage）保存敏感数据；强制 TLS，验证证书链，避免自签且不安全的验证逻辑。

深度解析：
- 讨论 token 生命周期、刷新机制、对本地数据的加密与备份策略、避免在 Dart 层硬编码密钥、以及对 PlatformChannel 入参做严格校验。

加分项：
- 介绍移动端防篡改（integrity checks）、App Attestation（安全检测）与 CI 中的 secret 管理最佳实践。

评分细则（10分）：
- 存储与传输安全 4 分；输入校验与本地安全 4 分；运维与策略 2 分
MD

mkdir -p samples/q37_security/lib
cat > samples/q37_security/lib/main.dart <<'DART'
import 'package:flutter/material.dart';
void main() => runApp(const MaterialApp(home: Scaffold(body: Center(child: Text('Security best practices notes')))));
DART

# Finalize commit
git add -A
git commit -m "Add batch Q28-Q37 docs and sample code snippets" || true

echo "Added docs/28-37 and samples/q28-q37 with sample main.dart files."
