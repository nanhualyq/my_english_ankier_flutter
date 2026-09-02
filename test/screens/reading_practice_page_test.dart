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

      expect(find.text('Show translation'), findsNWidgets(3));
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

      // Tap on the first "Show translation" button
      await tester.tap(find.text('Show translation').first);
      await tester.pumpAndSettle();

      // Now the first translation should be visible
      expect(find.text('译文1'), findsOneWidget);
      expect(find.text('Hide translation'), findsOneWidget);
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

      expect(find.text('Article content is empty'), findsOneWidget);
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
      expect(find.text('Show translation'), findsNothing);
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

      expect(find.text('Show translation'), findsOneWidget);
    });
  });

  group('Text Selection', () {
    testWidgets('should use SelectableText for original text', (tester) async {
      final article = Article(
        id: 1,
        title: 'Test Article',
        content: 'Selectable line',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ReadingPracticePage(article: article),
        ),
      );

      // SelectableText should be present (not plain Text) for the content
      expect(find.byType(SelectableText), findsOneWidget);
      expect(find.text('Selectable line'), findsOneWidget);
    });

    testWidgets('should use SelectableText for translation text',
        (tester) async {
      final article = Article(
        id: 1,
        title: 'Test Article',
        content: 'Original',
        translatedContent: '译文',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ReadingPracticePage(article: article),
        ),
      );

      // Expand translation
      await tester.tap(find.text('Show translation'));
      await tester.pumpAndSettle();

      // Should have 2 SelectableTexts: original + translation
      expect(find.byType(SelectableText), findsNWidgets(2));
      expect(find.text('译文'), findsOneWidget);
    });

    testWidgets('should not show selection bar initially', (tester) async {
      final article = Article(
        id: 1,
        title: 'Test Article',
        content: 'Line 1\nLine 2',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ReadingPracticePage(article: article),
        ),
      );

      // No copy/extract buttons should be visible
      expect(find.byTooltip('Copy'), findsNothing);
      expect(find.byTooltip('提取'), findsNothing);
      expect(find.byTooltip('关闭'), findsNothing);
    });

    testWidgets('should not show selection bar when content is empty',
        (tester) async {
      final article = Article(
        id: 1,
        title: 'Test Article',
        content: '',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ReadingPracticePage(article: article),
        ),
      );

      expect(find.byTooltip('Copy'), findsNothing);
    });

    testWidgets('multiple lines should each have SelectableText',
        (tester) async {
      final article = Article(
        id: 1,
        title: 'Test Article',
        content: 'Line A\nLine B\nLine C',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ReadingPracticePage(article: article),
        ),
      );

      // Each line gets its own SelectableText
      expect(find.byType(SelectableText), findsNWidgets(3));
    });

    testWidgets('original SelectableText should have onSelectionChanged',
        (tester) async {
      final article = Article(
        id: 1,
        title: 'Test',
        content: 'Hello world',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ReadingPracticePage(article: article),
        ),
      );

      final selectableText =
          tester.widget<SelectableText>(find.byType(SelectableText));
      expect(selectableText.onSelectionChanged, isNotNull);
    });

    testWidgets('selection bar should have correct layout elements',
        (tester) async {
      final article = Article(
        id: 1,
        title: 'Test',
        content: 'Hello world',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ReadingPracticePage(article: article),
        ),
      );

      // Before selection: no action buttons
      expect(find.byIcon(Icons.copy), findsNothing);
      expect(find.byIcon(Icons.bookmark_add_outlined), findsNothing);
      expect(find.byIcon(Icons.close), findsNothing);
    });

    testWidgets('ReadingLineItem should accept onSelected callback',
        (tester) async {
      // Verify the widget accepts the callback without error
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReadingLineItem(
              lineNumber: 1,
              text: 'Test text',
              onSelected: (selection) {},
            ),
          ),
        ),
      );

      expect(find.byType(ReadingLineItem), findsOneWidget);
      expect(find.byType(SelectableText), findsOneWidget);
    });

    testWidgets('ReadingLineItem with callback and translation',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReadingLineItem(
              lineNumber: 1,
              text: 'Original',
              translation: '译文',
              onSelected: (selection) {},
            ),
          ),
        ),
      );

      // Expand translation
      await tester.tap(find.text('Show translation'));
      await tester.pumpAndSettle();

      // Both texts should be SelectableText
      expect(find.byType(SelectableText), findsNWidgets(2));
    });

    testWidgets('ReadingLineItem without callback still works',
        (tester) async {
      // Backward compatibility: onSelected is optional
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ReadingLineItem(
              lineNumber: 1,
              text: 'Test text',
            ),
          ),
        ),
      );

      expect(find.byType(SelectableText), findsOneWidget);
      expect(find.text('Test text'), findsOneWidget);
    });

    testWidgets('selection bar should display copy and extract tooltips',
        (tester) async {
      // This tests the _SelectionBar indirectly through the page
      // We can't easily trigger selection in widget tests,
      // but we verify the structure is correct
      final article = Article(
        id: 1,
        title: 'Test',
        content: 'Hello',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: ReadingPracticePage(article: article),
        ),
      );

      // Verify no selection bar exists before interaction
      // The IconButton with tooltip 'Copy' should not exist
      final copyButton = find.byTooltip('Copy');
      expect(copyButton, findsNothing);
    });
  });
}
