## 1. 修改 Back 字段换行符

- [x] 1.1 修改 `lib/models/youdao_dict_result.dart` 中 `toBackField()` 方法，将 `join('\n')` 改为 `join('<br>')`，验证：阅读代码确认分隔符已变更
- [x] 1.2 在 `lib/utils/anki_field_builder.dart` 的 `buildAnkiFrontField` 函数注释中补充 Anki 字段换行规则说明，明确所有 Anki 字段内容中的换行必须使用 `<br>` 而非 `\n`，验证：代码注释中包含 `<br>` 换行规则说明
