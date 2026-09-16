import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_english_ankier_flutter/services/tts_service.dart';

void main() {
  group('TtsService', () {
    late TtsService service;

    setUp(() {
      service = TtsService();
    });

    tearDown(() {
      service.dispose();
    });

    test('synthesize returns null for empty text', () async {
      final result = await service.synthesize('');
      expect(result, isNull);
    });

    test('synthesize returns null for whitespace-only text', () async {
      final result = await service.synthesize('   ');
      expect(result, isNull);
    });

    test('synthesize returns a valid wav file path', () async {
      final result = await service.synthesize('Hello world');
      expect(result, isNotNull);
      expect(result, endsWith('.wav'));

      final file = File(result!);
      expect(file.existsSync(), isTrue);
      // wav 文件应大于 0 字节
      expect(file.lengthSync(), greaterThan(0));
    });

    test('synthesize caches result for same text', () async {
      final result1 = await service.synthesize('Test caching');
      final result2 = await service.synthesize('Test caching');

      expect(result1, equals(result2));
    });

    test('synthesize produces different files for different text', () async {
      final result1 = await service.synthesize('First sentence');
      final result2 = await service.synthesize('Second sentence');

      expect(result1, isNotNull);
      expect(result2, isNotNull);
      expect(result1, isNot(equals(result2)));
    });

    test('preSynthesize does not block caller', () async {
      // preSynthesize 应立即返回，不阻塞
      final stopwatch = Stopwatch()..start();
      service.preSynthesize('Pre-synthesize test');
      stopwatch.stop();

      // 应在极短时间内返回（< 100ms）
      expect(stopwatch.elapsedMilliseconds, lessThan(100));
    });
  });
}
