import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/youdao_dict_result.dart';

/// 有道词典查询服务
///
/// 通过有道词典 JSON API 查询英文单词释义。
/// 无需 API key，无需登录。
class YoudaoDictService {
  static const _baseUrl = 'https://dict.youdao.com/jsonapi';

  final http.Client _client;

  YoudaoDictService({http.Client? client}) : _client = client ?? http.Client();

  /// 查询单词释义
  ///
  /// 返回 [YoudaoDictResult]，查询失败或无结果时返回 null。
  Future<YoudaoDictResult?> lookup(String word) async {
    if (word.trim().isEmpty) return null;

    try {
      final uri = Uri.parse('$_baseUrl?q=${Uri.encodeComponent(word.trim())}');
      final response = await _client
          .get(uri)
          .timeout(const Duration(seconds: 5));

      if (response.statusCode != 200) return null;

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return _parseResponse(word.trim(), data);
    } catch (_) {
      // 网络异常、超时、解析失败均返回 null
      return null;
    }
  }

  /// 解析有道 API 响应
  YoudaoDictResult? _parseResponse(String word, Map<String, dynamic> data) {
    final entries = _parseEntries(data);
    final phonetics = _parsePhonetics(data);
    final webTranslations = _parseWebTranslations(data);

    // 至少要有一个有效释义才算成功
    if (entries.isEmpty && webTranslations.isEmpty) return null;

    final examples = _parseExamples(data);
    final synonyms = _parseSynonyms(data);
    final relatedWords = _parseRelatedWords(data);
    final examTypes = _parseExamTypes(data);

    return YoudaoDictResult(
      word: word,
      phonetics: phonetics,
      entries: entries,
      webTranslations: webTranslations,
      examples: examples,
      synonyms: synonyms,
      relatedWords: relatedWords,
      examTypes: examTypes,
    );
  }

  /// 解析词典释义
  ///
  /// 优先使用 expand_ec（结构化更好），回退到 ec 字段。
  List<DictEntry> _parseEntries(Map<String, dynamic> data) {
    // 优先尝试 expand_ec（结构化 pos + trans）
    final expandEc = data['expand_ec'];
    if (expandEc is Map) {
      final wordList = expandEc['word'];
      if (wordList is List && wordList.isNotEmpty) {
        final entries = <DictEntry>[];
        for (final w in wordList) {
          if (w is! Map) continue;
          final pos = w['pos'] as String? ?? '';
          final transList = w['transList'];
          if (transList is! List) continue;
          final transParts = <String>[];
          for (final t in transList) {
            if (t is! Map) continue;
            final trans = t['trans'] as String?;
            if (trans != null && trans.isNotEmpty) transParts.add(trans);
          }
          if (transParts.isNotEmpty) {
            entries.add(DictEntry(pos: pos, tran: transParts.join('；')));
          }
        }
        if (entries.isNotEmpty) return entries;
      }
    }

    // 回退到 ec 字段
    final ec = data['ec'];
    if (ec is! Map) return [];

    final wordList = ec['word'];
    if (wordList is! List || wordList.isEmpty) return [];

    final word = wordList[0];
    if (word is! Map) return [];

    final trs = word['trs'];
    if (trs is! List) return [];

    final entries = <DictEntry>[];
    for (final tr in trs) {
      if (tr is! Map) continue;
      // ec 结构: {"tr": [{"l": {"i": ["adj. 短暂的..."]}}]}
      final trArray = tr['tr'];
      if (trArray is! List || trArray.isEmpty) continue;
      final first = trArray[0];
      if (first is! Map) continue;
      final l = first['l'];
      if (l is! Map) continue;
      final i = l['i'];
      if (i is! List || i.isEmpty) continue;
      final text = i[0].toString();
      // 格式: "adj. 短暂的；短命的" — 尝试分离词性和释义
      final dotIdx = text.indexOf('. ');
      if (dotIdx > 0 && dotIdx < 10) {
        entries.add(DictEntry(
          pos: '${text.substring(0, dotIdx + 1)} ',
          tran: text.substring(dotIdx + 2),
        ));
      } else {
        entries.add(DictEntry(pos: '', tran: text));
      }
    }
    return entries;
  }

  /// 解析音标
  List<Phonetic> _parsePhonetics(Map<String, dynamic> data) {
    final phonetics = <Phonetic>[];

    // 尝试从 simple 字段获取
    final simple = data['simple'];
    if (simple is Map) {
      final wordList = simple['word'];
      if (wordList is List && wordList.isNotEmpty) {
        final w = wordList[0];
        if (w is Map) {
          final ukphone = w['ukphone'] as String?;
          final usphone = w['usphone'] as String?;
          if (ukphone != null && ukphone.isNotEmpty) {
            phonetics.add(Phonetic(
              region: 'UK',
              text: ukphone,
              speechUrl: w['ukspeech'] as String?,
            ));
          }
          if (usphone != null && usphone.isNotEmpty) {
            phonetics.add(Phonetic(
              region: 'US',
              text: usphone,
              speechUrl: w['usspeech'] as String?,
            ));
          }
        }
      }
    }

    // 回退到 ec 字段
    if (phonetics.isEmpty) {
      final ec = data['ec'];
      if (ec is Map) {
        final wordList = ec['word'];
        if (wordList is List && wordList.isNotEmpty) {
          final w = wordList[0];
          if (w is Map) {
            final ukphone = w['ukphone'] as String?;
            final usphone = w['usphone'] as String?;
            if (ukphone != null && ukphone.isNotEmpty) {
              phonetics.add(Phonetic(region: 'UK', text: ukphone));
            }
            if (usphone != null && usphone.isNotEmpty) {
              phonetics.add(Phonetic(region: 'US', text: usphone));
            }
          }
        }
      }
    }

    return phonetics;
  }

  /// 解析网络释义
  List<WebTranslation> _parseWebTranslations(Map<String, dynamic> data) {
    final webTrans = data['web_trans'];
    if (webTrans is! Map) return [];

    final webTranslation = webTrans['web-translation'];
    if (webTranslation is! List) return [];

    final results = <WebTranslation>[];
    for (final item in webTranslation) {
      if (item is! Map) continue;
      final trans = item['trans'];
      if (trans is! List) continue;
      for (final t in trans) {
        if (t is! Map) continue;
        final value = t['value'] as String?;
        if (value == null || value.isEmpty) continue;
        results.add(WebTranslation(
          value: value,
          support: t['support'] as int? ?? 0,
        ));
      }
    }
    return results;
  }

  /// 解析双语例句
  List<Example> _parseExamples(Map<String, dynamic> data) {
    final blng = data['blng_sents_part'];
    if (blng is! Map) return [];

    final pairs = blng['sentence-pair'];
    if (pairs is! List) return [];

    final examples = <Example>[];
    for (final pair in pairs) {
      if (pair is! Map) continue;
      final en = pair['sentence'] as String?;
      final zh = pair['sentence-translation'] as String?;
      if (en == null || zh == null) continue;
      examples.add(Example(
        en: _stripHtml(en),
        zh: zh,
        source: pair['source'] as String?,
      ));
    }
    return examples;
  }

  /// 解析同近义词
  List<SynonymGroup> _parseSynonyms(Map<String, dynamic> data) {
    final syno = data['syno'];
    if (syno is! Map) return [];

    final synos = syno['synos'];
    if (synos is! List) return [];

    final groups = <SynonymGroup>[];
    for (final s in synos) {
      if (s is! Map) continue;
      final pos = s['pos'] as String? ?? '';
      final ws = s['ws'];
      final tran = s['tran'] as String? ?? '';
      if (ws is! List) continue;
      final words = ws.map((w) => w is Map ? (w['w'] as String? ?? '') : '')
          .where((w) => w.isNotEmpty)
          .toList();
      if (words.isEmpty) continue;
      groups.add(SynonymGroup(pos: pos, words: words, tran: tran));
    }
    return groups;
  }

  /// 解析同根词
  List<RelatedWord> _parseRelatedWords(Map<String, dynamic> data) {
    final relWord = data['rel_word'];
    if (relWord is! Map) return [];

    final rels = relWord['rels'];
    if (rels is! List) return [];

    final words = <RelatedWord>[];
    for (final rel in rels) {
      if (rel is! Map) continue;
      final relData = rel['rel'];
      if (relData is! Map) continue;
      final pos = relData['pos'] as String?;
      final wordList = relData['words'];
      if (wordList is! List) continue;
      for (final w in wordList) {
        if (w is! Map) continue;
        final word = w['word'] as String?;
        if (word == null || word.isEmpty) continue;
        words.add(RelatedWord(
          word: word,
          pos: pos,
          tran: w['tran'] as String?,
        ));
      }
    }
    return words;
  }

  /// 解析考试标注
  List<String> _parseExamTypes(Map<String, dynamic> data) {
    final ec = data['ec'];
    if (ec is! Map) return [];

    final examType = ec['exam_type'];
    if (examType is! List) return [];

    return examType.map((e) => e.toString()).toList();
  }

  /// 去除 HTML 标签
  String _stripHtml(String html) {
    return html.replaceAll(RegExp(r'<[^>]*>'), '');
  }
}
