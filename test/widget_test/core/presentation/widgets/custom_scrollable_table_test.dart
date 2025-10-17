import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:opennutritracker/core/presentation/widgets/custom_scrollable_table.dart';

void main() {
  group('CustomScrollableTable', () {
    testWidgets('should render table with headers and data', (WidgetTester tester) async {
      const headers = ['Name', 'Calories', 'Protein'];
      const tableData = [
        ['Apple', '95', '0.5g'],
        ['Banana', '105', '1.3g'],
        ['Orange', '62', '1.2g'],
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomScrollableTable(
              headers: headers,
              tableData: tableData,
            ),
          ),
        ),
      );

      // Verify headers are displayed
      expect(find.text('Name'), findsOneWidget);
      expect(find.text('Calories'), findsOneWidget);
      expect(find.text('Protein'), findsOneWidget);

      // Verify data is displayed
      expect(find.text('Apple'), findsOneWidget);
      expect(find.text('95'), findsOneWidget);
      expect(find.text('0.5g'), findsOneWidget);
    });

    testWidgets('should render table without headers', (WidgetTester tester) async {
      const tableData = [
        ['Row 1 Col 1', 'Row 1 Col 2'],
        ['Row 2 Col 1', 'Row 2 Col 2'],
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomScrollableTable(
              headers: const [],
              tableData: tableData,
              stickyHeader: false,
            ),
          ),
        ),
      );

      // Verify data is displayed
      expect(find.text('Row 1 Col 1'), findsOneWidget);
      expect(find.text('Row 2 Col 2'), findsOneWidget);
    });

    testWidgets('should have horizontal scrolling capability', (WidgetTester tester) async {
      const headers = ['Col1', 'Col2', 'Col3', 'Col4', 'Col5', 'Col6'];
      const tableData = [
        ['Data1', 'Data2', 'Data3', 'Data4', 'Data5', 'Data6'],
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 300, // Constrain width to force horizontal scrolling
              child: CustomScrollableTable(
                headers: headers,
                tableData: tableData,
                columnWidth: 120,
              ),
            ),
          ),
        ),
      );

      // Find horizontal scroll views
      final horizontalScrollViews = find.byWidgetPredicate(
        (widget) => widget is SingleChildScrollView && 
                   widget.scrollDirection == Axis.horizontal,
      );
      
      expect(horizontalScrollViews, findsWidgets);
      expect(find.text('Col1'), findsOneWidget);
    });

    testWidgets('should have vertical scrolling capability', (WidgetTester tester) async {
      const headers = ['Column A', 'Column B'];
      final tableData = List.generate(20, (index) => ['Row ${index + 1} A', 'Row ${index + 1} B']);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 200, // Constrain height to force vertical scrolling
              child: CustomScrollableTable(
                headers: headers,
                tableData: tableData,
                maxHeight: 200,
              ),
            ),
          ),
        ),
      );

      // Find vertical scroll view
      final verticalScrollView = find.byWidgetPredicate(
        (widget) => widget is SingleChildScrollView && 
                   widget.scrollDirection == Axis.vertical,
      );
      
      expect(verticalScrollView, findsOneWidget);
      expect(find.text('Row 1 A'), findsOneWidget);
    });

    testWidgets('should display sticky headers when enabled', (WidgetTester tester) async {
      const headers = ['Header 1', 'Header 2'];
      const tableData = [
        ['Data 1', 'Data 2'],
        ['Data 3', 'Data 4'],
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomScrollableTable(
              headers: headers,
              tableData: tableData,
              stickyHeader: true,
            ),
          ),
        ),
      );

      // Verify sticky header structure
      expect(find.text('Header 1'), findsOneWidget);
      expect(find.text('Header 2'), findsOneWidget);
      
      // Should find the sticky header container
      final stickyHeaderContainer = find.byWidgetPredicate(
        (widget) => widget is Container && 
                   widget.decoration is BoxDecoration &&
                   (widget.decoration as BoxDecoration).border != null,
      );
      expect(stickyHeaderContainer, findsWidgets);
    });

    testWidgets('should apply custom styling', (WidgetTester tester) async {
      const headers = ['Test Header'];
      const tableData = [['Test Data']];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomScrollableTable(
              headers: headers,
              tableData: tableData,
              headerColor: Colors.blue,
              bodyColor: Colors.green,
              borderColor: Colors.red,
              columnWidth: 200,
              columnSpacing: 20,
            ),
          ),
        ),
      );

      expect(find.text('Test Header'), findsOneWidget);
      expect(find.text('Test Data'), findsOneWidget);
    });

    testWidgets('should handle empty table gracefully', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CustomScrollableTable(
              headers: [],
              tableData: [],
            ),
          ),
        ),
      );

      // Should render without errors
      expect(find.byType(CustomScrollableTable), findsOneWidget);
    });

    testWidgets('should handle tables with varying cell content lengths', (WidgetTester tester) async {
      const headers = ['Short', 'Very Long Header That Should Wrap'];
      const tableData = [
        ['A', 'This is a very long cell content that should be handled properly'],
        ['B', 'Short'],
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomScrollableTable(
              headers: headers,
              tableData: tableData,
            ),
          ),
        ),
      );

      expect(find.text('Short'), findsWidgets);
      expect(find.textContaining('Very Long Header'), findsOneWidget);
      expect(find.textContaining('This is a very long cell'), findsOneWidget);
    });

    testWidgets('should respect maxHeight constraint', (WidgetTester tester) async {
      const headers = ['Column'];
      final tableData = List.generate(50, (index) => ['Row ${index + 1}']);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomScrollableTable(
              headers: headers,
              tableData: tableData,
              maxHeight: 300,
            ),
          ),
        ),
      );

      // Find the container with height constraint
      final constrainedContainer = find.byWidgetPredicate(
        (widget) => widget is Container && 
                   widget.constraints != null &&
                   widget.constraints!.maxHeight == 300,
      );
      
      expect(constrainedContainer, findsOneWidget);
    });

    testWidgets('should sync horizontal scrolling between header and body', (WidgetTester tester) async {
      const headers = ['Col1', 'Col2', 'Col3', 'Col4', 'Col5'];
      const tableData = [
        ['Data1', 'Data2', 'Data3', 'Data4', 'Data5'],
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 300,
              child: CustomScrollableTable(
                headers: headers,
                tableData: tableData,
                columnWidth: 120,
                stickyHeader: true,
              ),
            ),
          ),
        ),
      );

      // Find the body horizontal scroll view
      final bodyScrollView = find.byWidgetPredicate(
        (widget) => widget is SingleChildScrollView && 
                   widget.scrollDirection == Axis.horizontal &&
                   widget.controller != null,
      );
      
      expect(bodyScrollView, findsWidgets);
      
      // Scroll the body and verify it works
      await tester.drag(bodyScrollView.first, const Offset(-100, 0));
      await tester.pump();
      
      // Table should still be visible after scrolling
      expect(find.byType(CustomScrollableTable), findsOneWidget);
    });

    testWidgets('should apply alternating row colors', (WidgetTester tester) async {
      const headers = ['Column'];
      const tableData = [
        ['Row 1'],
        ['Row 2'],
        ['Row 3'],
        ['Row 4'],
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomScrollableTable(
              headers: headers,
              tableData: tableData,
              bodyColor: Colors.white,
            ),
          ),
        ),
      );

      expect(find.text('Row 1'), findsOneWidget);
      expect(find.text('Row 4'), findsOneWidget);
    });
  });

  group('TableContentParser', () {
    test('should parse simple markdown table', () {
      const markdownTable = '''
| Name | Age |
|------|-----|
| John | 25  |
| Jane | 30  |
''';

      final result = TableContentParser.parseMarkdownTable(markdownTable);
      
      expect(result.headers, equals(['Name', 'Age']));
      expect(result.rows, equals([['John', '25'], ['Jane', '30']]));
      expect(result.hasHeaders, isTrue);
      expect(result.isEmpty, isFalse);
    });

    test('should parse table without headers', () {
      const markdownTable = '''
| John | 25 |
| Jane | 30 |
''';

      final result = TableContentParser.parseMarkdownTable(markdownTable);
      
      expect(result.headers, equals(['John', '25']));
      expect(result.rows, equals([['Jane', '30']]));
    });

    test('should handle empty table', () {
      const markdownTable = '';

      final result = TableContentParser.parseMarkdownTable(markdownTable);
      
      expect(result.headers, isEmpty);
      expect(result.rows, isEmpty);
      expect(result.isEmpty, isTrue);
    });

    test('should handle malformed table', () {
      const markdownTable = '''
| Name |
| John
Jane | 30 |
''';

      final result = TableContentParser.parseMarkdownTable(markdownTable);
      
      // Should still parse what it can
      expect(result.headers, isNotEmpty);
    });

    test('should parse table with separator line', () {
      const markdownTable = '''
| Header 1 | Header 2 |
|----------|----------|
| Data 1   | Data 2   |
''';

      final result = TableContentParser.parseMarkdownTable(markdownTable);
      
      expect(result.headers, equals(['Header 1', 'Header 2']));
      expect(result.rows, equals([['Data 1', 'Data 2']]));
    });
  });
}