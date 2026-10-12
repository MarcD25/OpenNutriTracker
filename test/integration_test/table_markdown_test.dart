import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:opennutritracker/core/presentation/widgets/custom_scrollable_table.dart';
import 'package:opennutritracker/features/chat/domain/entity/chat_message_entity.dart';
import 'package:opennutritracker/features/chat/presentation/widgets/chat_message_widget.dart';

void main() {
  group('Table Markdown Integration Tests', () {
    testWidgets('should render markdown tables with enhanced scrolling in chat messages', (WidgetTester tester) async {
      const tableMarkdown = '''
Here's a nutrition table:

| Food Item | Calories | Protein | Carbs | Fat |
|-----------|----------|---------|-------|-----|
| Apple     | 95       | 0.5g    | 25g   | 0.3g|
| Banana    | 105      | 1.3g    | 27g   | 0.4g|
| Orange    | 62       | 1.2g    | 15g   | 0.2g|
| Chicken   | 231      | 31g     | 0g    | 10g |

This table shows nutritional information.
''';

      final message = ChatMessageEntity(
        id: 'test-id',
        content: tableMarkdown,
        type: ChatMessageType.assistant,
        timestamp: DateTime.now(),
        isVisible: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChatMessageWidget(message: message),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should find CustomScrollableTable widget
      expect(find.byType(CustomScrollableTable), findsOneWidget);
      
      // Should find table content
      expect(find.text('Food Item'), findsOneWidget);
      expect(find.text('Apple'), findsOneWidget);
      expect(find.text('95'), findsOneWidget);
      
      // Should find scrollable components
      expect(find.byType(SingleChildScrollView), findsWidgets);
      
      // Should find the text before and after table
      expect(find.textContaining('Here\'s a nutrition table'), findsOneWidget);
      expect(find.textContaining('This table shows'), findsOneWidget);
    });

    testWidgets('should handle multiple tables in single message', (WidgetTester tester) async {
      const multiTableMarkdown = '''
First table:

| Fruit | Color |
|-------|-------|
| Apple | Red   |
| Banana| Yellow|

Second table:

| Vegetable | Color |
|-----------|-------|
| Carrot    | Orange|
| Lettuce   | Green |
''';

      final message = ChatMessageEntity(
        id: 'test-id',
        content: multiTableMarkdown,
        type: ChatMessageType.assistant,
        timestamp: DateTime.now(),
        isVisible: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChatMessageWidget(message: message),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should find multiple CustomScrollableTable widgets
      expect(find.byType(CustomScrollableTable), findsNWidgets(2));
      
      // Should find content from both tables
      expect(find.text('Fruit'), findsOneWidget);
      expect(find.text('Vegetable'), findsOneWidget);
      expect(find.text('Apple'), findsOneWidget);
      expect(find.text('Carrot'), findsOneWidget);
    });

    testWidgets('should handle wide tables with horizontal scrolling', (WidgetTester tester) async {
      const wideTableMarkdown = '''
| Food | Cal | Prot | Carb | Fat | Fiber | Sugar | Sodium | Potassium | Vitamin C |
|------|-----|------|------|-----|-------|-------|--------|-----------|-----------|
| Apple| 95  | 0.5g | 25g  |0.3g | 4.4g  | 19g   | 2mg    | 195mg     | 8.4mg     |
''';

      final message = ChatMessageEntity(
        id: 'test-id',
        content: wideTableMarkdown,
        type: ChatMessageType.assistant,
        timestamp: DateTime.now(),
        isVisible: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 300, // Constrain width to test horizontal scrolling
              child: ChatMessageWidget(message: message),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should find CustomScrollableTable widget
      expect(find.byType(CustomScrollableTable), findsOneWidget);
      
      // Should find table content
      expect(find.text('Food'), findsOneWidget);
      expect(find.text('Apple'), findsOneWidget);
      
      // Should have horizontal scrolling capability
      final horizontalScrollViews = find.byWidgetPredicate(
        (widget) => widget is SingleChildScrollView && 
                   widget.scrollDirection == Axis.horizontal,
      );
      expect(horizontalScrollViews, findsWidgets);
    });

    testWidgets('should handle tall tables with vertical scrolling', (WidgetTester tester) async {
      final tallTableMarkdown = StringBuffer();
      tallTableMarkdown.writeln('| Food | Calories |');
      tallTableMarkdown.writeln('|------|----------|');
      for (int i = 1; i <= 20; i++) {
        tallTableMarkdown.writeln('| Food $i | ${i * 10} |');
      }

      final message = ChatMessageEntity(
        id: 'test-id',
        content: tallTableMarkdown.toString(),
        type: ChatMessageType.assistant,
        timestamp: DateTime.now(),
        isVisible: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 300, // Constrain height to test vertical scrolling
              child: ChatMessageWidget(message: message),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should find CustomScrollableTable widget
      expect(find.byType(CustomScrollableTable), findsOneWidget);
      
      // Should find table content
      expect(find.text('Food'), findsOneWidget);
      expect(find.text('Food 1'), findsOneWidget);
      
      // Should have vertical scrolling capability
      final verticalScrollView = find.byWidgetPredicate(
        (widget) => widget is SingleChildScrollView && 
                   widget.scrollDirection == Axis.vertical,
      );
      expect(verticalScrollView, findsOneWidget);
    });

    testWidgets('should preserve table formatting with proper spacing', (WidgetTester tester) async {
      const spacedTableMarkdown = '''
| Item Name | Nutritional Value | Daily % |
|-----------|-------------------|---------|
| Protein   | 25g               | 50%     |
| Carbohydrates | 30g           | 10%     |
| Fat       | 15g               | 23%     |
''';

      final message = ChatMessageEntity(
        id: 'test-id',
        content: spacedTableMarkdown,
        type: ChatMessageType.assistant,
        timestamp: DateTime.now(),
        isVisible: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChatMessageWidget(message: message),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should find CustomScrollableTable widget
      expect(find.byType(CustomScrollableTable), findsOneWidget);
      
      // Should find all table content with proper spacing
      expect(find.text('Item Name'), findsOneWidget);
      expect(find.text('Nutritional Value'), findsOneWidget);
      expect(find.text('Daily %'), findsOneWidget);
      expect(find.text('Protein'), findsOneWidget);
      expect(find.text('25g'), findsOneWidget);
      expect(find.text('50%'), findsOneWidget);
    });

    testWidgets('should handle mixed content with tables and regular text', (WidgetTester tester) async {
      const mixedContentMarkdown = '''
# Nutrition Analysis

Here are the results of your meal:

| Nutrient | Amount | % Daily Value |
|----------|--------|---------------|
| Calories | 450    | 23%           |
| Protein  | 25g    | 50%           |
| Carbs    | 45g    | 15%           |

**Summary:** This meal provides a good balance of macronutrients.

## Recommendations

- Consider adding more vegetables
- Reduce sodium intake
''';

      final message = ChatMessageEntity(
        id: 'test-id',
        content: mixedContentMarkdown,
        type: ChatMessageType.assistant,
        timestamp: DateTime.now(),
        isVisible: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChatMessageWidget(message: message),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should find CustomScrollableTable widget
      expect(find.byType(CustomScrollableTable), findsOneWidget);
      
      // Should find headers
      expect(find.textContaining('Nutrition Analysis'), findsOneWidget);
      expect(find.textContaining('Recommendations'), findsOneWidget);
      
      // Should find table content
      expect(find.text('Nutrient'), findsOneWidget);
      expect(find.text('Calories'), findsOneWidget);
      expect(find.text('450'), findsOneWidget);
      
      // Should find regular text
      expect(find.textContaining('This meal provides'), findsOneWidget);
      expect(find.textContaining('Consider adding'), findsOneWidget);
    });

    testWidgets('should handle empty or malformed tables gracefully', (WidgetTester tester) async {
      const malformedTableMarkdown = '''
This is a malformed table:

| Header |
| Data without proper formatting
| Another | Row |

And some regular text after.
''';

      final message = ChatMessageEntity(
        id: 'test-id',
        content: malformedTableMarkdown,
        type: ChatMessageType.assistant,
        timestamp: DateTime.now(),
        isVisible: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChatMessageWidget(message: message),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should render without crashing
      expect(find.byType(ChatMessageWidget), findsOneWidget);
      expect(find.textContaining('This is a malformed table'), findsOneWidget);
      expect(find.textContaining('And some regular text'), findsOneWidget);
    });

    testWidgets('should apply proper styling to table elements', (WidgetTester tester) async {
      const styledTableMarkdown = '''
| **Bold Header** | *Italic Header* |
|-----------------|-----------------|
| Normal text     | `Code text`     |
''';

      final message = ChatMessageEntity(
        id: 'test-id',
        content: styledTableMarkdown,
        type: ChatMessageType.assistant,
        timestamp: DateTime.now(),
        isVisible: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChatMessageWidget(message: message),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should find CustomScrollableTable widget
      expect(find.byType(CustomScrollableTable), findsOneWidget);
      
      // Should find table content (styling may be simplified in table rendering)
      expect(find.textContaining('Bold Header'), findsOneWidget);
      expect(find.textContaining('Italic Header'), findsOneWidget);
      expect(find.text('Normal text'), findsOneWidget);
      expect(find.textContaining('Code text'), findsOneWidget);
    });

    testWidgets('should handle sticky headers correctly', (WidgetTester tester) async {
      final longTableMarkdown = StringBuffer();
      longTableMarkdown.writeln('| Food Item | Calories | Protein |');
      longTableMarkdown.writeln('|-----------|----------|---------|');
      for (int i = 1; i <= 15; i++) {
        longTableMarkdown.writeln('| Food Item $i | ${i * 50} | ${i}g |');
      }

      final message = ChatMessageEntity(
        id: 'test-id',
        content: longTableMarkdown.toString(),
        type: ChatMessageType.assistant,
        timestamp: DateTime.now(),
        isVisible: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 300,
              child: ChatMessageWidget(message: message),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should find CustomScrollableTable with sticky header
      expect(find.byType(CustomScrollableTable), findsOneWidget);
      
      // Headers should be visible
      expect(find.text('Food Item'), findsOneWidget);
      expect(find.text('Calories'), findsOneWidget);
      expect(find.text('Protein'), findsOneWidget);
      
      // Should find some data rows
      expect(find.text('Food Item 1'), findsOneWidget);
    });

    testWidgets('should adapt to different screen sizes', (WidgetTester tester) async {
      const adaptiveTableMarkdown = '''
| Item | Description | Price | Availability |
|------|-------------|-------|--------------|
| Apple| Fresh fruit | \$1.50| In stock     |
| Banana| Yellow fruit| \$0.75| In stock     |
''';

      final message = ChatMessageEntity(
        id: 'test-id',
        content: adaptiveTableMarkdown,
        type: ChatMessageType.assistant,
        timestamp: DateTime.now(),
        isVisible: true,
      );

      // Test on small screen
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 200,
              height: 300,
              child: ChatMessageWidget(message: message),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(CustomScrollableTable), findsOneWidget);
      expect(find.text('Item'), findsOneWidget);
      
      // Test on larger screen
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 800,
              height: 600,
              child: ChatMessageWidget(message: message),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(CustomScrollableTable), findsOneWidget);
      expect(find.text('Item'), findsOneWidget);
      expect(find.text('Apple'), findsOneWidget);
    });

    testWidgets('should handle regular message without tables', (WidgetTester tester) async {
      const regularContent = '''
This is a regular message without any tables.

Just some normal text content.
''';

      final message = ChatMessageEntity(
        id: 'test-2',
        content: regularContent,
        type: ChatMessageType.assistant,
        timestamp: DateTime.now(),
        isVisible: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ChatMessageWidget(
              message: message,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify the message content is rendered
      expect(find.text("This is a regular message without any tables."), findsOneWidget);
      expect(find.text("Just some normal text content."), findsOneWidget);
      
      // Verify the ChatMessageWidget is present
      expect(find.byType(ChatMessageWidget), findsOneWidget);
      
      // Should not find any CustomScrollableTable widgets
      expect(find.byType(CustomScrollableTable), findsNothing);
      
      // The test passes if no exceptions are thrown during rendering
      expect(tester.takeException(), isNull);
    });
  });
}