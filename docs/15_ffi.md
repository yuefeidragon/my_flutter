# Q15：Dart FFI 深入：内存管理、回调、struct 对齐与跨平台构建

标准答案要点：
- FFI 通过 C ABI 调用本地函数，数据必须 marshal（Bytes / Utf8 / malloc），注意 free；回调需用 NativePort 或 NativeCallable；struct 对齐需与 C 头文件一致。
- 跨平台构建要考虑各平台的编译链与 ABI（arm64/x86_64），并用 CI 做多平台 binary 构建。

加分项：
- 讨论 panic/unwind、线程模型（不要在 Dart isolate 里直接访问非线程安全代码）、以及如何在 Dart 层封装安全接口。
评分细则（10分）：基础概念 4分；内存与回调细节 4分；跨平台构建 2分
