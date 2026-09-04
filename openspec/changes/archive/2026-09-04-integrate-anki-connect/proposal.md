## Why

用户在阅读练习页面选中英文单词或短语后，需要手动创建 Anki 卡片来记忆。当前 `_extractSelection()` 仅显示 SnackBar 占位提示，无法实际创建闪卡。需要集成 AnkiConnect 插件，让用户选中文本后一键打开 Anki 的添加卡片界面，预填 Front 字段（含上下文和高亮），减少手动操作。

## What Changes

- 新增 `lib/services/anki_connect_service.dart`：封装 AnkiConnect HTTP API（`guiAddCards`、`isAvailable`）
- 新增 `http` 依赖（pubspec.yaml）
- 修改 `reading_practice_page.dart` 中的 `_extractSelection()`：
  - 检测 AnkiConnect 是否可用
  - 构建 Front 字段 HTML（上方3行上下文 + 当前行选中部分 `<mark>` 高亮 + 隐藏时间戳去重，多行间用 `<br>` 换行）
  - 调用 `guiAddCards` 打开 Anki 原生添加界面
- 硬编码参数：deck=`English`、model=`@Basic`

## Capabilities

### Modified Capabilities
- `ui-reading-practice`: 将"提取"按钮从占位 SnackBar 改为实际调用 AnkiConnect 创建卡片

## Impact

- 新增文件：`lib/services/anki_connect_service.dart`
- 修改文件：`lib/screens/reading_practice_page.dart`、`pubspec.yaml`
- 新增依赖：`http: ^1.2.0`
- 运行时依赖：用户需安装 AnkiConnect 插件（addon code: `2055492159`）并保持 Anki 运行
- 仅支持桌面平台（Windows/macOS/Linux），通过 `localhost:8765` 通信
