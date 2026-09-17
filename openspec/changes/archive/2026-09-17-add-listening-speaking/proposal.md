## Why

当前应用只有阅读和写作两种练习模式。听力和口语是英语学习的另外两个核心技能，需要对应的练习页面来形成完整的四技能训练体系。听力练习的核心是"先听后看"，口语练习的核心是"边看边读"。

## What Changes

- 新增听力练习页面（ListeningPracticePage）：每行默认只显示 TTS 播放按钮，展开后才显示原文，支持文本选中
- 新增口语练习页面（SpeakingPracticePage）：每行显示原文 + TTS 播放按钮，始终可见，支持文本选中
- 扩展 PracticeLineItem 组件：新增 `showPrimaryText`、`primaryTextExpandable`、`trailing` 参数以支持听/说模式
- 扩展 Anki 字段构建：`buildAnkiFrontField` 新增 `highlightReplacement` 参数，听力模式下选中部分替换为 `???`
- 更新 ArticleCard 和 SkillProgressWidget：添加听力和口语的点击导航
- 更新 HomePage：添加导航到听力和口语练习页面的方法
- 听力使用 Anki notetype `@EnSpeak`，口语使用 `@EnSpeak`（注：原需求为 `@EnListen` 和 `@EnSpeak`）

## Capabilities

### New Capabilities
- `ui-listening-practice`: 听力练习页面的 UI 和交互行为
- `ui-speaking-practice`: 口语练习页面的 UI 和交互行为

### Modified Capabilities
- `ui-homepage`: 文章卡片的 🎧 和 🗣️ 进度条变为可点击，导航到对应练习页面

## Impact

- `lib/widgets/practice_line_item.dart` — 扩展参数
- `lib/utils/anki_field_builder.dart` — 新增 highlightReplacement 参数
- `lib/widgets/skill_progress_widget.dart` — 新增 onListeningTap/onSpeakingTap
- `lib/widgets/article_card.dart` — 新增回调传递
- `lib/screens/home_page.dart` — 新增导航方法
- `lib/screens/listening_practice_page.dart` — 新建
- `lib/screens/speaking_practice_page.dart` — 新建
