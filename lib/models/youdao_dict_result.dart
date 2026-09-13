/// 有道词典查询结果的完整数据模型
///
/// 存储有道 JSON API 返回的所有有价值信息。
/// 当前仅使用 [entries] 填充 Anki Back 字段，
/// 其他字段为后续功能预留。
class YoudaoDictResult {
  /// 查询的单词
  final String word;

  /// 音标列表（英式/美式）
  final List<Phonetic> phonetics;

  /// 词典释义（词性 + 中文翻译）
  final List<DictEntry> entries;

  /// 网络释义
  final List<WebTranslation> webTranslations;

  /// 双语例句
  final List<Example> examples;

  /// 同近义词
  final List<SynonymGroup> synonyms;

  /// 同根词
  final List<RelatedWord> relatedWords;

  /// 考试标注（如 TOEFL, GRE, SAT）
  final List<String> examTypes;

  const YoudaoDictResult({
    required this.word,
    this.phonetics = const [],
    this.entries = const [],
    this.webTranslations = const [],
    this.examples = const [],
    this.synonyms = const [],
    this.relatedWords = const [],
    this.examTypes = const [],
  });

  /// 是否有有效释义
  bool get hasEntries => entries.isNotEmpty;

  /// 将所有词性释义格式化为 Anki Back 字段内容
  ///
  /// 格式：每行一个 `词性 释义`
  String toBackField() {
    if (entries.isEmpty) return '';
    return entries.map((e) => '${e.pos} ${e.tran}').join('\n');
  }
}

/// 音标
class Phonetic {
  /// 地区标识（UK / US）
  final String region;

  /// 音标文本（如 ɪˈfemərəl）
  final String text;

  /// 发音音频 URL
  final String? speechUrl;

  const Phonetic({
    required this.region,
    required this.text,
    this.speechUrl,
  });
}

/// 词典释义条目
class DictEntry {
  /// 词性（如 adj. / n. / v.）
  final String pos;

  /// 中文释义
  final String tran;

  const DictEntry({required this.pos, required this.tran});
}

/// 网络释义
class WebTranslation {
  /// 翻译值
  final String value;

  /// 支持数
  final int support;

  const WebTranslation({required this.value, this.support = 0});
}

/// 双语例句
class Example {
  /// 英文例句
  final String en;

  /// 中文翻译
  final String zh;

  /// 来源
  final String? source;

  const Example({required this.en, required this.zh, this.source});
}

/// 同近义词组
class SynonymGroup {
  /// 词性
  final String pos;

  /// 同义词列表
  final List<String> words;

  /// 中文翻译
  final String tran;

  const SynonymGroup({
    required this.pos,
    required this.words,
    required this.tran,
  });
}

/// 同根词
class RelatedWord {
  /// 单词
  final String word;

  /// 词性
  final String? pos;

  /// 中文翻译
  final String? tran;

  const RelatedWord({required this.word, this.pos, this.tran});
}
