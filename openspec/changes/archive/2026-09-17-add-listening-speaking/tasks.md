## 1. 扩展通用组件

- [x] 1.1 扩展 `PracticeLineItem`：新增 `showPrimaryText`、`primaryTextExpandable`、`trailing` 三个参数，验证现有阅读/写作页面行为不变
- [x] 1.2 扩展 `buildAnkiFrontField`：新增 `highlightReplacement` 参数，验证传 `'???'` 时选中部分替换为问号，传空时行为不变

## 2. 听力练习页面

- [x] 2.1 新建 `ListeningPracticePage`，每行默认只显示 TTS 播放按钮和展开控件，验证展开后显示原文
- [x] 2.2 实现选中提取逻辑：notetype 为 `@EnListen`，Front 使用 `highlightReplacement='???'`，Back 填入选中原文，验证 Anki Add Cards 对话框正确打开

## 3. 口语练习页面

- [x] 3.1 新建 `SpeakingPracticePage`，每行始终显示原文和 TTS 播放按钮（TTS 单独一行），验证文本可选中
- [x] 3.2 实现选中提取逻辑：notetype 为 `@EnSpeak`，Front 使用默认高亮，Back 填入选中原文，验证 Anki Add Cards 对话框正确打开

## 4. 首页导航集成

- [x] 4.1 扩展 `SkillProgressWidget`：新增 `onListeningTap`/`onSpeakingTap` 回调，验证 🎧 和 🗣️ 变为可点击
- [x] 4.2 扩展 `ArticleCard`：新增 `onListeningPractice`/`onSpeakingPractice` 回调并传递到 `_ProgressRow`
- [x] 4.3 扩展 `HomePage`：新增 `_openListeningPractice`/`_openSpeakingPractice` 导航方法，验证点击 🎧/🗣️ 正确跳转

## 5. 验证

- [x] 5.1 运行现有测试，确认阅读/写作功能未被破坏
- [x] 5.2 手动验证听力页面：TTS 播放、展开原文、选中提取到 Anki
- [x] 5.3 手动验证口语页面：TTS 播放、选中提取到 Anki
