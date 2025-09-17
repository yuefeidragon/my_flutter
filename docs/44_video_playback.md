# Q44：视频播放与缓冲策略

标准答案要点：
- 使用合适播放器（video_player、exoplayer）、合理 buffer 配置、预加载与 adaptive bitrate 支持，降低卡顿。
深度解析：
- 说明缓冲窗口、seek 行为、后台播放与资源释放的实现细节。
加分项：
- 讨论 DRM、加密流与低延迟播放方案。
评分细则（10分）：播放器与 buffer 4分；实现细节 4分；安全/DRM 2分
