import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_english_ankier_flutter/models/article.dart';
import 'package:my_english_ankier_flutter/screens/reading_practice_page.dart';

void main() {
  group('ReadingPracticePage', () {
    testWidgets('should display article title in AppBar', (tester) async {
      final article = Article(
        id: 1,
        title: 'Test Article',
        content: 'Line 1\nLine 2\nLine 3',
        translatedContent: '译文1\n译文2\n译文3',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ReadingPracticePage(article: article),
        ),
      );

      expect(find.text('Test Article'), findsOneWidget);
    });

    testWidgets('should display all lines', (tester) async {
      final article = Article(
        id: 1,
        title: 'Test Article',
        content: 'Line 1\nLine 2\nLine 3',
        translatedContent: '译文1\n译文2\n译文3',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ReadingPracticePage(article: article),
        ),
      );

      expect(find.text('Line 1'), findsOneWidget);
      expect(find.text('Line 2'), findsOneWidget);
      expect(find.text('Line 3'), findsOneWidget);
    });

    testWidgets('should show translation toggle buttons', (tester) async {
      final article = Article(
        id: 1,
        title: 'Test Article',
        content: 'Line 1\nLine 2\nLine 3',
        translatedContent: '译文1\n译文2\n译文3',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ReadingPracticePage(article: article),
        ),
      );

      expect(find.text('显示译文'), findsNWidgets(3));
    });

    testWidgets('should toggle translation visibility', (tester) async {
      final article = Article(
        id: 1,
        title: 'Test Article',
        content: 'Line 1\nLine 2\nLine 3',
        translatedContent: '译文1\n译文2\n译文3',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ReadingPracticePage(article: article),
        ),
      );

      // Initially, translations should be hidden
      expect(find.text('译文1'), findsNothing);
      expect(find.text('译文2'), findsNothing);
      expect(find.text('译文3'), findsNothing);

      // Tap on the first "显示译文" button
      await tester.tap(find.text('显示译文').first);
      await tester.pumpAndSettle();

      // Now the first translation should be visible
      expect(find.text('译文1'), findsOneWidget);
      expect(find.text('收起译文'), findsOneWidget);
    });

    testWidgets('should handle empty content', (tester) async {
      final article = Article(
        id: 1,
        title: 'Test Article',
        content: '',
        translatedContent: null,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ReadingPracticePage(article: article),
        ),
      );

      expect(find.text('文章内容为空'), findsOneWidget);
    });

    testWidgets('should handle no translation', (tester) async {
      final article = Article(
        id: 1,
        title: 'Test Article',
        content: 'Line 1\nLine 2',
        translatedContent: null,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ReadingPracticePage(article: article),
        ),
      );

      expect(find.text('Line 1'), findsOneWidget);
      expect(find.text('Line 2'), findsOneWidget);
      expect(find.text('显示译文'), findsNothing);
    });

    testWidgets('should handle translation shorter than content', (tester) async {
      final article = Article(
        id: 1,
        title: 'Test Article',
        content: 'Line 1\nLine 2\nLine 3',
        translatedContent: '译文1',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ReadingPracticePage(article: article),
        ),
      );

      expect(find.text('显示译文'), findsOneWidget);
    });
  });
}
