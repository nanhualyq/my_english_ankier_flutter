import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:my_english_ankier_flutter/services/youdao_dict_service.dart';

/// 简单的 Mock HTTP Client，用于测试
class _MockClient implements http.Client {
  final String? responseBody;
  final int statusCode;
  final bool throwOnRequest;

  _MockClient({
    this.responseBody,
    this.statusCode = 200,
    this.throwOnRequest = false,
  });

  @override
  Future<http.Response> get(Uri url, {Map<String, String>? headers}) async {
    if (throwOnRequest) throw Exception('Network error');
    final body = responseBody ?? '{}';
    return http.Response.bytes(
      utf8.encode(body),
      statusCode,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    throw UnimplementedError();
  }
}

/// 模拟有道 API 的正常响应
const _mockYoudaoResponse = '''
{
  "ec": {
    "word": [{
      "usphone": "ɪˈfemərəl",
      "ukphone": "ɪˈfemərəl",
      "trs": [
        {"tr": [{"l": {"i": ["adj. 短暂的；（主指植物）短生的，短命的"]}}]},
        {"tr": [{"l": {"i": ["n. 只生存一天的事物；短生植物"]}}]}
      ]
    }],
    "exam_type": ["TOEFL", "GRE", "SAT"]
  },
  "expand_ec": {
    "word": [
      {
        "pos": "adj.",
        "transList": [
          {"trans": "短暂的"},
          {"trans": "（主指植物）短生的，短命的"}
        ]
      },
      {
        "pos": "n.",
        "transList": [
          {"trans": "只生存一天的事物"},
          {"trans": "短生植物"}
        ]
      }
    ]
  },
  "simple": {
    "query": "ephemeral",
    "word": [{"usphone": "ɪˈfemərəl", "ukphone": "ɪˈfemərəl"}]
  },
  "blng_sents_part": {
    "sentence-pair": [
      {
        "sentence": "He talked about the ephemeral unity.",
        "sentence-translation": "他谈到短暂的统一。"
      }
    ]
  },
  "syno": {
    "synos": [
      {"pos": "adj.", "ws": [{"w": "brief"}, {"w": "transient"}], "tran": "短暂的"}
    ]
  },
  "rel_word": {
    "rels": [
      {"rel": {"pos": "n.", "words": [{"word": "ephemerality", "tran": "短命"}]}}
    ]
  },
  "web_trans": {
    "web-translation": [
      {"trans": [{"value": "短暂的", "support": 1712}, {"value": "朝生暮死的", "support": 276}]}
    ]
  }
}
''';

void main() {
  group('YoudaoDictService', () {
    test('lookup returns result for valid word', () async {
      final client = _MockClient(responseBody: _mockYoudaoResponse);
      final service = YoudaoDictService(client: client);

      final result = await service.lookup('ephemeral');

      expect(result, isNotNull);
      expect(result!.word, 'ephemeral');
      expect(result.entries, hasLength(2));
      expect(result.entries[0].pos, 'adj.');
      expect(result.entries[0].tran, '短暂的；（主指植物）短生的，短命的');
      expect(result.entries[1].pos, 'n.');
      expect(result.entries[1].tran, '只生存一天的事物；短生植物');
    });

    test('lookup parses phonetics', () async {
      final client = _MockClient(responseBody: _mockYoudaoResponse);
      final service = YoudaoDictService(client: client);

      final result = await service.lookup('ephemeral');

      expect(result!.phonetics, hasLength(2));
      expect(result.phonetics[0].region, 'UK');
      expect(result.phonetics[0].text, 'ɪˈfemərəl');
      expect(result.phonetics[1].region, 'US');
    });

    test('lookup parses examples', () async {
      final client = _MockClient(responseBody: _mockYoudaoResponse);
      final service = YoudaoDictService(client: client);

      final result = await service.lookup('ephemeral');

      expect(result!.examples, isNotEmpty);
      expect(result.examples[0].zh, '他谈到短暂的统一。');
    });

    test('lookup parses synonyms', () async {
      final client = _MockClient(responseBody: _mockYoudaoResponse);
      final service = YoudaoDictService(client: client);

      final result = await service.lookup('ephemeral');

      expect(result!.synonyms, isNotEmpty);
      expect(result.synonyms[0].words, contains('brief'));
    });

    test('lookup parses web translations', () async {
      final client = _MockClient(responseBody: _mockYoudaoResponse);
      final service = YoudaoDictService(client: client);

      final result = await service.lookup('ephemeral');

      expect(result!.webTranslations, isNotEmpty);
      expect(result.webTranslations[0].value, '短暂的');
    });

    test('lookup parses exam types', () async {
      final client = _MockClient(responseBody: _mockYoudaoResponse);
      final service = YoudaoDictService(client: client);

      final result = await service.lookup('ephemeral');

      expect(result!.examTypes, contains('TOEFL'));
      expect(result.examTypes, contains('GRE'));
    });

    test('lookup parses related words', () async {
      final client = _MockClient(responseBody: _mockYoudaoResponse);
      final service = YoudaoDictService(client: client);

      final result = await service.lookup('ephemeral');

      expect(result!.relatedWords, isNotEmpty);
      expect(result.relatedWords[0].word, 'ephemerality');
    });

    test('toBackField formats correctly', () async {
      final client = _MockClient(responseBody: _mockYoudaoResponse);
      final service = YoudaoDictService(client: client);

      final result = await service.lookup('ephemeral');
      final back = result!.toBackField();

      expect(back, 'adj. 短暂的；（主指植物）短生的，短命的\nn. 只生存一天的事物；短生植物');
    });

    test('lookup returns null for empty response', () async {
      final client = _MockClient(responseBody: '{}');
      final service = YoudaoDictService(client: client);

      final result = await service.lookup('xyznotaword');

      expect(result, isNull);
    });

    test('lookup returns null on network error', () async {
      final client = _MockClient(throwOnRequest: true);
      final service = YoudaoDictService(client: client);

      final result = await service.lookup('hello');

      expect(result, isNull);
    });

    test('lookup returns null on non-200 status', () async {
      final client = _MockClient(responseBody: '{}', statusCode: 500);
      final service = YoudaoDictService(client: client);

      final result = await service.lookup('hello');

      expect(result, isNull);
    });

    test('lookup returns null for empty word', () async {
      final client = _MockClient(responseBody: _mockYoudaoResponse);
      final service = YoudaoDictService(client: client);

      final result = await service.lookup('  ');

      expect(result, isNull);
    });

    test('lookup returns null for malformed JSON', () async {
      final client = _MockClient(responseBody: 'not json');
      final service = YoudaoDictService(client: client);

      final result = await service.lookup('hello');

      expect(result, isNull);
    });
  });
}
