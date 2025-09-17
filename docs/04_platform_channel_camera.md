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
