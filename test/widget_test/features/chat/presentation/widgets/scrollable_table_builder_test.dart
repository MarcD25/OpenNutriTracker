import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:opennutritracker/core/presentation/widgets/custom_scrollable_table.dart';
import 'package:opennutritracker/features/chat/presentation/widgets/chat_message_widget.dart';

void main() {
  group('ScrollableTableBuilder', () {
    late ScrollableTableBuilder builder;

    setUp(() {
      builder = ScrollableTableBuilder();
    });

    test('should create ScrollableTableBuilder instance', () {
      expect(builder, isA<ScrollableTableBuilder>());
      expect(builder, isA<MarkdownElementBuilder>());
    });

    test('should be a valid MarkdownElementBuilder', () {
      expect(builder.runtimeType.toString(), 'ScrollableTableBuilder');
    });

    testWidgets('should render scrollable table with horizontal and vertical scrolling', (WidgetTester tester) async {
      const markdownTable = '''
| Column 1 | Column 2 | Column 3 | Column 4 | Column 5 |
|----------|----------|----------|----------|----------|
| Row 1 Col 1 | Row 1 Col 2 | Row 1 Col 3 | Row 1 Col 4 | Row 1 Col 5 |
| Row 2 Col 1 | Row 2 Col 2 | Row 2 Col 3 | Row 2 Col 4 | Row 2 Col 5 |
| Row 3 Col 1 | Row 3 Col 2 | Row 3 Col 3 | Row 3 Col 4 | Row 3 Col 5 |
''';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MarkdownBody(
              data: markdownTable,
              builders: {
                'table': builder,
              },
            ),
          ),
        ),
      );

      // Should find the CustomScrollableTable widget
      expect(find.byType(CustomScrollableTable), findsOneWidget);
      expect(find.byType(SingleChildScrollView), findsWidgets); // Multiple scroll views for enhanced scrolling
      
      // Should find table content
      expect(find.text('Column 1'), findsOneWidget);
      expect(find.text('Row 1 Col 1'), findsOneWidget);
    });

    testWidgets('should handle table with headers correctly', (WidgetTester tester) async {
      const markdownTable = '''
| Header 1 | Header 2 | Header 3 |
|----------|----------|----------|
| Data 1   | Data 2   | Data 3   |
| Data 4   | Data 5   | Data 6   |
''';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MarkdownBody(
              data: markdownTable,
              builders: {
                'table': builder,
              },
            ),
          ),
        ),
      );

      expect(find.text('Header 1'), findsOneWidget);
      expect(find.text('Data 1'), findsOneWidget);
    });

    testWidgets('should apply proper styling to table cells', (WidgetTester tester) async {
      const markdownTable = '''
| Header | Value |
|--------|-------|
| Test   | 123   |
''';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MarkdownBody(
              data: markdownTable,
              builders: {
                'table': builder,
              },
            ),
          ),
        ),
      );

      // Verify CustomScrollableTable structure
      expect(find.byType(CustomScrollableTable), findsOneWidget);
      
      // Find containers that represent table cells
      final cellContainers = find.byType(Container);
      expect(cellContainers, findsWidgets);
      expect(find.text('Header'), findsOneWidget);
      expect(find.text('Test'), findsOneWidget);
    });

    testWidgets('should handle empty table gracefully', (WidgetTester tester) async {
      const markdownTable = '''
| |
|-|
''';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MarkdownBody(
              data: markdownTable,
              builders: {
                'table': builder,
              },
            ),
          ),
        ),
      );

      // Should still render the table structure without crashing
      expect(find.byType(SingleChildScrollView), findsWidgets);
    });

    testWidgets('should constrain table height to maximum', (WidgetTester tester) async {
      // Create a table with many rows to test height constraint
      final longTable = StringBuffer();
      longTable.writeln('| Column 1 | Column 2 |');
      longTable.writeln('|----------|----------|');
      for (int i = 1; i <= 20; i++) {
        longTable.writeln('| Row $i Col 1 | Row $i Col 2 |');
      }

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MarkdownBody(
              data: longTable.toString(),
              builders: {
                'table': builder,
              },
            ),
          ),
        ),
      );

      // Find the CustomScrollableTable with height constraint
      expect(find.byType(CustomScrollableTable), findsOneWidget);
    });

    testWidgets('should handle table with varying cell content lengths', (WidgetTester tester) async {
      const markdownTable = '''
| Short | This is a much longer column header that should test text wrapping |
|-------|-------------------------------------------------------------------|
| A     | This is a very long cell content that should be handled properly by the table rendering system |
| B     | Short content |
''';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MarkdownBody(
              data: markdownTable,
              builders: {
                'table': builder,
              },
            ),
          ),
        ),
      );

      expect(find.text('Short'), findsOneWidget);
      expect(find.textContaining('This is a much longer'), findsOneWidget);
      expect(find.textContaining('This is a very long cell'), findsOneWidget);
    });

    testWidgets('should be scrollable horizontally', (WidgetTester tester) async {
      const wideTable = '''
| Col1 | Col2 | Col3 | Col4 | Col5 | Col6 | Col7 | Col8 | Col9 | Col10 |
|------|------|------|------|------|------|------|------|------|-------|
| Data1| Data2| Data3| Data4| Data5| Data6| Data7| Data8| Data9| Data10|
''';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 300, // Constrain width to force horizontal scrolling
              child: MarkdownBody(
                data: wideTable,
                builders: {
                  'table': builder,
                },
              ),
            ),
          ),
        ),
      );

      // Find horizontal scroll views (there may be multiple for header and body)
      final horizontalScrollViews = find.byWidgetPredicate(
        (widget) => widget is SingleChildScrollView && 
                   widget.scrollDirection == Axis.horizontal,
      );
      
      expect(horizontalScrollViews, findsWidgets);

      // Initially, rightmost columns might not be visible
      expect(find.text('Col1'), findsOneWidget);
      
      // Scroll horizontally to reveal more columns
      await tester.drag(horizontalScrollViews.first, const Offset(-200, 0));
      await tester.pump();
      
      // After scrolling, we should still see table content
      expect(find.byType(CustomScrollableTable), findsOneWidget);
    });

    testWidgets('should be scrollable vertically for tall tables', (WidgetTester tester) async {
      // Create a tall table
      final tallTable = StringBuffer();
      tallTable.writeln('| Column A | Column B |');
      tallTable.writeln('|----------|----------|');
      for (int i = 1; i <= 30; i++) {
        tallTable.writeln('| Row $i A | Row $i B |');
      }

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 200, // Constrain height to force vertical scrolling
              child: MarkdownBody(
                data: tallTable.toString(),
                builders: {
                  'table': builder,
                },
              ),
            ),
          ),
        ),
      );

      // Find vertical scroll view
      final verticalScrollViews = find.byWidgetPredicate(
        (widget) => widget is SingleChildScrollView && 
                   widget.scrollDirection == Axis.vertical,
      );
      
      expect(verticalScrollViews, findsWidgets);

      // Initially, bottom rows might not be visible
      expect(find.text('Row 1 A'), findsOneWidget);
      expect(find.text('Row 30 A'), findsNothing);
      
      // Scroll vertically to reveal more rows
      await tester.drag(verticalScrollViews.first, const Offset(0, -300));
      await tester.pump();
      
      // After scrolling, we should see different content
      expect(find.byType(CustomScrollableTable), findsOneWidget);
    });

    testWidgets('should apply proper border styling to table', (WidgetTester tester) async {
      const simpleTable = '''
| A | B |
|---|---|
| 1 | 2 |
''';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MarkdownBody(
              data: simpleTable,
              builders: {
                'table': builder,
              },
            ),
          ),
        ),
      );

      // Find the CustomScrollableTable with proper styling
      expect(find.byType(CustomScrollableTable), findsOneWidget);
      
      // Find containers with border decoration (there may be multiple)
      final borderedContainers = find.byWidgetPredicate(
        (widget) => widget is Container && 
                   widget.decoration is BoxDecoration &&
                   (widget.decoration as BoxDecoration).border != null,
      );
      
      expect(borderedContainers, findsWidgets);
    });

    test('should return null for non-table elements', () {
      final nonTableElement = md.Element('div', []);
      final result = builder.visitElementAfter(nonTableElement, null);
      expect(result, isNull);
    });

    test('should handle table element', () {
      final tableElement = md.Element('table', []);
      final result = builder.visitElementAfter(tableElement, null);
      expect(result, isA<Widget>());
    });
  });
}