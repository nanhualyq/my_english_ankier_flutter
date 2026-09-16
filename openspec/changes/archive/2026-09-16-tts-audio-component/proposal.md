## Why

应用目前无法朗读英文文本。对于英语学习工具来说，听觉输入是不可或缺的一环——用户需要听到正确的发音来训练听力和口语。本次新增基于 Windows 系统内置 TTS 的音频合成与播放能力，为后续的听力/口语练习页面奠定基础。

## What Changes

- 新增 `TtsService`：通过 PowerShell 调用 Windows `System.Speech.Synthesis`，将英文文本合成为 `.wav` 临时文件
- 新增 `TtsPlayButton`：内嵌式播放按钮组件，点击即播放音频，再次点击可停止或重播
- 使用 PowerShell `System.Media.SoundPlayer` 播放 wav 文件，零第三方音频依赖
- 支持预合成策略：播放当前行时，后台自动合成相邻 3 行（+1/+2/+3），减少后续播放延迟
- 使用文本 hash 做文件名去重，同一文本不重复合成
- 合成任务串行队列，防止并发 PowerShell 进程过多

## Capabilities

### New Capabilities
- `tts-audio`: 基于 Windows 系统 TTS 的文本朗读能力，包括文本合成服务和内嵌式音频播放器组件

### Modified Capabilities
（无）

## Impact

- **新增文件**：`lib/services/tts_service.dart`、`lib/widgets/tts_play_button.dart`
- **新增依赖**：无（仅使用 PowerShell 系统命令）
- **平台限制**：仅 Windows（依赖 PowerShell + System.Speech）
- **后续集成**：本 change 不涉及听说页面集成，仅交付可复用的服务和组件
