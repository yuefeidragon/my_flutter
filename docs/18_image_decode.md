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
