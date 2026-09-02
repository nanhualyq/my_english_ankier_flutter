import 'package:flutter_test/flutter_test.dart';
import 'package:my_english_ankier_flutter/models/selected_content.dart';

void main() {
  group('SelectedContent Model', () {
    test('should create instance with all required fields', () {
      const content = SelectedContent(
        lineNumber: 1,
        lineText: 'The quick brown fox',
        selectedText: 'quick',
        start: 4,
        end: 9,
      );

      expect(content.lineNumber, 1);
      expect(content.lineText, 'The quick brown fox');
      expect(content.selectedText, 'quick');
      expect(content.start, 4);
      expect(content.end, 9);
      expect(content.isTranslation, false);
    });

    test('should create instance with isTranslation true', () {
      const content = SelectedContent(
        lineNumber: 2,
        lineText: '敏捷的棕色狐狸',
        selectedText: '棕色',
        start: 2,
        end: 4,
        isTranslation: true,
      );

      expect(content.isTranslation, true);
      expect(content.selectedText, '棕色');
    });

    test('should default isTranslation to false', () {
      const content = SelectedContent(
        lineNumber: 1,
        lineText: 'Hello world',
        selectedText: 'world',
        start: 6,
        end: 11,
      );

      expect(content.isTranslation, false);
    });

    test('should handle single character selection', () {
      const content = SelectedContent(
        lineNumber: 1,
        lineText: 'Hello',
        selectedText: 'H',
        start: 0,
        end: 1,
      );

      expect(content.selectedText.length, 1);
      expect(content.start, content.end - 1);
    });

    test('should handle selection at start of line', () {
      const content = SelectedContent(
        lineNumber: 1,
        lineText: 'Hello world',
        selectedText: 'Hello',
        start: 0,
        end: 5,
      );

      expect(content.start, 0);
    });

    test('should handle selection at end of line', () {
      const content = SelectedContent(
        lineNumber: 1,
        lineText: 'Hello world',
        selectedText: 'world',
        start: 6,
        end: 11,
      );

      expect(content.end, 11);
    });

    test('should handle selection of entire line', () {
      const line = 'The quick brown fox jumps over the lazy dog';
      final content = SelectedContent(
        lineNumber: 1,
        lineText: line,
        selectedText: line,
        start: 0,
        end: line.length,
      );

      expect(content.selectedText, content.lineText);
      expect(content.start, 0);
      expect(content.end, line.length);
    });

    test('should handle empty selectedText edge case', () {
      // This shouldn't happen in practice (filtered by UI),
      // but the model should still work
      const content = SelectedContent(
        lineNumber: 1,
        lineText: 'Hello',
        selectedText: '',
        start: 2,
        end: 2,
      );

      expect(content.selectedText, '');
      expect(content.start, content.end);
    });

    test('toString should contain key info', () {
      const content = SelectedContent(
        lineNumber: 3,
        lineText: 'Some text',
        selectedText: 'text',
        start: 5,
        end: 9,
      );

      final str = content.toString();

      expect(str, contains('3'));
      expect(str, contains('text'));
      expect(str, contains('5-9'));
      expect(str, contains('false'));
    });

    test('toString should reflect isTranslation true', () {
      const content = SelectedContent(
        lineNumber: 1,
        lineText: '原文',
        selectedText: '文',
        start: 1,
        end: 2,
        isTranslation: true,
      );

      expect(content.toString(), contains('true'));
    });

    test('should support const construction', () {
      // Verify the class can be used as a compile-time constant
      const content1 = SelectedContent(
        lineNumber: 1,
        lineText: 'a',
        selectedText: 'a',
        start: 0,
        end: 1,
      );
      const content2 = SelectedContent(
        lineNumber: 1,
        lineText: 'a',
        selectedText: 'a',
        start: 0,
        end: 1,
      );

      // Dart deduplicates identical const values, so they are the same object
      expect(identical(content1, content2), isTrue);
      expect(content1.lineText, 'a');
    });
  });
}
