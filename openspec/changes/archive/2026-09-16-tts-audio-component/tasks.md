## 1. 依赖与基础设施

- [x] 1.1 确认无额外音频依赖（仅使用 PowerShell 系统命令播放）
- [x] 1.2 创建 `lib/services/tts_service.dart` 文件骨架（类定义、导入），验证文件可被 Dart 分析器识别

## 2. TtsService 核心实现

- [x] 2.1 实现 `synthesize(String text)` 方法：通过 `Process.run` 调用 PowerShell 执行 System.Speech 合成 wav 文件到 `%TEMP%` 目录，返回文件路径；验证输入英文短句后生成有效 wav 文件
- [x] 2.2 实现 hash 缓存机制：以文本内容 hash（前 16 位 hex）为文件名，内存 Map 维护缓存映射；验证相同文本第二次调用直接返回缓存路径且不启动新进程
- [x] 2.3 实现合成失败处理：PowerShell 非零退出码或超时（10 秒）返回 null；验证无效输入不抛异常
- [x] 2.4 实现 `preSynthesize(String text)` 方法：fire-and-forget 调用 synthesize；验证调用后不阻塞调用方

## 3. 串行队列与预合成

- [x] 3.1 实现串行合成队列：所有合成任务（synthesize 和 preSynthesize）通过队列串行执行；验证并发调用时同一时间仅一个 PowerShell 进程运行
- [x] 3.2 实现优先级机制：用户触发的播放请求可插入队列前端或取消当前预合成任务；验证从第 1 行跳到第 10 行时，第 10 行立即开始合成

## 4. TtsPlayButton 组件

- [x] 4.1 创建 `lib/widgets/tts_play_button.dart`，实现内嵌式 IconButton：喇叭图标（idle）、停止图标（playing）、CircularProgressIndicator（loading）；验证组件可独立渲染无报错
- [x] 4.2 集成 PowerShell SoundPlayer 播放：点击按钮触发合成 → 播放，使用 `Process.start` 运行 `SoundPlayer.PlaySync()`；验证点击后音频正常播放
- [x] 4.3 实现播放中停止：播放中再次点击 kill 进程停止播放；验证停止后按钮恢复喇叭图标
- [x] 4.4 实现重播：播完后 `_completed` 标记重置，再次点击从头播放；验证播完后点击可重播

## 5. 集成验证

- [x] 5.1 编写 `TtsService` 单元测试：覆盖合成成功、缓存命中、合成失败三种场景；验证所有测试通过
- [x] 5.2 编写 `TtsPlayButton` widget 测试：覆盖播放触发、合成状态显示、停止播放场景；验证所有测试通过
- [x] 5.3 运行 `flutter analyze` 确认无 lint 错误
