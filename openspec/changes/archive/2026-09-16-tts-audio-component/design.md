## Context

本项目是一个 Flutter Windows 桌面应用（英语学习 Anki 工具）。当前已有 `PracticeLineItem` 组件用于逐行显示文章内容，支持文本选中。本次新增 TTS 音频播放能力，需要一个合成服务和一个播放器组件。

Windows 系统内置 `System.Speech.Synthesis` TTS 引擎，可通过 PowerShell 调用。经实测，合成一个 10 词英文句子约 171ms，产出 ~145KB 的 wav 文件。系统已安装 Microsoft David Desktop (en-US) 和 Microsoft Zira Desktop (en-US) 两个英语语音。

## Goals / Non-Goals

**Goals:**
- 提供可复用的 `TtsService`，封装 PowerShell TTS 合成逻辑
- 提供可复用的 `TtsPlayButton` 组件，可嵌入任何列表项
- 通过预合成策略消除行间切换的延迟感
- 合成失败时静默跳过，不影响用户操作

**Non-Goals:**
- 不涉及听力/口语练习页面的实现（后续 change）
- 不提供语音选择器 UI（使用系统默认语音）
- 不做跨平台支持（仅 Windows）
- 不主动管理临时文件生命周期（依赖 OS 清理）

## Decisions

### 1. TTS 合成方案：PowerShell + System.Speech

**选择**: 通过 `Process.run` 调用 PowerShell，执行 `System.Speech.Synthesis.SpeechSynthesizer` 合成 wav 文件。

**备选方案**:
- `flutter_tts` 包：跨平台，但增加第三方依赖，对 Windows SAPI 控制有限
- Dart FFI 直接调用 COM：零依赖，但实现复杂度极高

**理由**: PowerShell 方案零依赖、实测延迟仅 ~171ms、实现简单。对于仅 Windows 平台的项目，这是最轻量的方案。

### 2. 音频播放方案：PowerShell SoundPlayer

**选择**: 通过 `Process.start` 启动 PowerShell 进程，使用 `System.Media.SoundPlayer.PlaySync()` 播放 wav 文件。播放期间按钮显示停止图标，点击可 kill 进程停止播放。

**备选方案**:
- `just_audio`：功能完善，但 Windows 平台插件兼容性差（MissingPluginException）
- `audioplayers`：Windows 上 seek 超时、线程安全问题严重
- `flutter_tts` 自带 `speak()`：无独立控制，无法停止播放

**理由**: PowerShell SoundPlayer 零依赖、零兼容性问题、实测可靠。虽然不支持 seek/进度条，但对于短句朗读场景完全够用。

### 3. 缓存策略：hash 文件名 + 内存 Map

**选择**: 以文本内容的 hash（取前 16 位 hex）作为文件名，存于 `%TEMP%\tts_<hash>.wav`。内存中维护 `Map<String, String>`（hash → 文件路径）缓存映射。

**理由**: hash 文件名天然去重，即使 app 重启，临时文件仍存在（OS 未清理时），可直接复用。内存 Map 提供快速的缓存查找。

### 4. 预合成策略：窗口大小 3

**选择**: 播放第 N 行时，后台预合成 N+1、N+2、N+3。

**理由**: 经实测单次合成 ~171ms，3 行预合成总耗时 ~500ms。用户通常逐行前进，3 行窗口覆盖绝大多数场景。过多预合成会占用不必要的 CPU 和磁盘。

### 5. 并发控制：串行队列

**选择**: 所有合成任务（包括预合成和用户触发）通过串行队列执行，同一时间仅运行一个 PowerShell 进程。用户触发的播放请求具有更高优先级——插入队列前端或取消当前预合成。

**备选方案**:
- 无限制并发：可能同时启动多个 PowerShell 进程，占用过多资源
- 固定大小线程池：实现复杂度高于收益

**理由**: 串行队列最简单，且合成延迟很低（~171ms），不会造成明显排队等待。

### 6. TtsPlayButton 组件形态：内嵌 IconButton

**选择**: TtsPlayButton 是一个简单的 `IconButton`，显示喇叭图标（idle）或停止图标（playing），可直接嵌入 `ListTile.trailing` 等位置。合成中显示 `CircularProgressIndicator`。

**理由**: 对于短句朗读场景，复杂的播放器 UI（进度条、seek、时间显示）是过度设计。一个点击即播的按钮最简洁、最可靠。

## Risks / Trade-offs

- **[PowerShell 进程开销]** 每次合成都启动一个新 PowerShell 进程，有 ~300ms 冷启动开销 → 已通过实测确认总延迟仅 ~171ms，可接受。若后续发现瓶颈，可考虑长期运行的 PowerShell 进程（stdin/stdout 通信）。
- **[仅 Windows 平台]** TTS 功能完全依赖 Windows 系统 → 后续如需跨平台，可替换 TtsService 内部实现为 `flutter_tts`，接口不变。
- **[临时文件不清理]** 依赖 OS 清理 `%TEMP%` 目录 → 单个 wav 文件 ~145KB，即使积累数百个也仅几十 MB，风险极低。
- **[SoundPlayer 无 seek]** PowerShell SoundPlayer 不支持 seek/进度显示 → 对于短句朗读（<10秒）场景可接受，后续如需进度条可切换到其他方案。
