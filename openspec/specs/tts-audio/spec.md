## Purpose

提供基于 Windows 系统内置 TTS 的英文文本朗读能力，包括文本到音频的合成服务和内嵌式音频播放器组件，为听力/口语练习页面奠定基础。

## Requirements

### Requirement: 文本转语音合成
系统 SHALL 通过 Windows 系统内置的 TTS 服务（System.Speech.Synthesis）将英文文本合成为 `.wav` 音频文件。合成结果缓存在系统临时目录中，以文本内容的 hash 值作为文件名，同一文本不重复合成。

#### Scenario: 合成英文短句
- **WHEN** 调用合成接口，输入文本 "The quick brown fox jumps over the lazy dog"
- **THEN** 在系统临时目录生成有效的 `.wav` 文件，返回该文件路径

#### Scenario: 相同文本不重复合成
- **WHEN** 连续两次调用合成接口，输入相同文本
- **THEN** 第二次调用直接返回缓存路径，不启动新的合成进程

#### Scenario: 合成失败
- **WHEN** PowerShell 进程异常退出或超时（10 秒）
- **THEN** 返回 null，不抛出异常

### Requirement: 预合成相邻行
系统 SHALL 在播放当前行时，后台自动预合成相邻的后续 3 行文本（+1、+2、+3），以减少用户切换到下一行时的播放延迟。

#### Scenario: 播放第 N 行时预合成
- **WHEN** 用户触发播放第 N 行
- **THEN** 系统在后台静默启动第 N+1、N+2、N+3 行的合成任务，不阻塞当前播放

#### Scenario: 预合成结果命中
- **WHEN** 用户播放第 N 行，且第 N+1 行已完成预合成
- **THEN** 用户点击播放第 N+1 行时直接使用缓存文件，无需等待合成

### Requirement: 合成任务串行执行
系统 SHALL 将所有合成任务（包括预合成）放入串行队列，同一时间仅执行一个 PowerShell 合成进程。

#### Scenario: 多个合成请求并发到达
- **WHEN** 同时触发 3 个合成任务
- **THEN** 任务按队列顺序依次执行，不同时启动多个 PowerShell 进程

#### Scenario: 用户跳转到未预合成的行
- **WHEN** 用户从第 1 行直接跳到第 10 行播放，第 10 行未在预合成队列中
- **THEN** 系统取消旧的预合成队列，立即合成第 10 行并播放，然后重新排队第 11、12、13 行

### Requirement: 播放按钮
系统 SHALL 提供一个播放按钮组件（TtsPlayButton），用于播放 TTS 合成的音频。按钮为内嵌式 IconButton，可嵌入列表项中。

#### Scenario: 首次点击播放
- **WHEN** 用户点击某行的播放按钮
- **THEN** 按钮显示加载指示器，合成完成后自动播放音频，按钮变为停止图标

#### Scenario: 播放中点击停止
- **WHEN** 音频正在播放时用户点击按钮
- **THEN** 音频立即停止，按钮恢复为喇叭图标

#### Scenario: 播完后再次点击
- **WHEN** 音频播放完成后用户再次点击按钮
- **THEN** 从头重新播放同一段音频

#### Scenario: 合成失败
- **WHEN** 音频合成失败
- **THEN** 加载指示器消失，按钮恢复为喇叭图标，不显示错误提示

### Requirement: 系统默认语音
系统 SHALL 使用 Windows 系统默认 TTS 语音进行合成，不提供语音选择器。

#### Scenario: 使用默认语音
- **WHEN** 调用合成接口，未指定语音参数
- **THEN** 使用系统默认英语语音（通常是 Microsoft David Desktop 或 Microsoft Zira Desktop）合成
