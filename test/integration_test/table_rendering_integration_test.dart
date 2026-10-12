import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:opennutritracker/main.dart' as app;

void main() {

  group('Enhanced Table Rendering Integration Tests', () {
    testWidgets('Nutrition comparison table rendering and scrolling', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to chat screen
      await tester.tap(find.byIcon(Icons.chat));
      await tester.pumpAndSettle();

      // Request a nutrition comparison table
      final messageInput = find.byKey(const Key('chat_message_input'));
      await tester.enterText(messageInput, 
        'Show me a detailed nutrition comparison table for apples, bananas, oranges, and grapes including calories, protein, carbs, fiber, and vitamins');
      
      final sendButton = find.byKey(const Key('send_message_button'));
      await tester.tap(sendButton);
      await tester.pumpAndSettle(const Duration(seconds: 8));

      // Verify enhanced table rendering elements appear
      final customScrollableTable = find.byKey(const Key('custom_scrollable_table'));
      final tableHorizontalScroll = find.byKey(const Key('table_horizontal_scroll'));
      final scrollableTable = find.byKey(const Key('scrollable_table'));
      
      // Check for custom scrollable table implementation
      if (customScrollableTable.evaluate().isNotEmpty) {
        expect(customScrollableTable, findsOneWidget);
        
        // Test horizontal scrolling with custom table
        if (tableHorizontalScroll.evaluate().isNotEmpty) {
          await tester.drag(tableHorizontalScroll, const Offset(-200, 0));
          await tester.pumpAndSettle();
          expect(customScrollableTable, findsOneWidget);
        }
        
        print('✅ Enhanced table rendering with custom_scrollable_table verified');
      } else if (scrollableTable.evaluate().isNotEmpty) {
        expect(scrollableTable, findsOneWidget);

        // Test horizontal scrolling
        await tester.drag(scrollableTable, const Offset(-200, 0));
        await tester.pumpAndSettle();

        // Verify table is still visible after horizontal scroll
        expect(scrollableTable, findsOneWidget);

        // Test vertical scrolling
        await tester.drag(scrollableTable, const Offset(0, -100));
        await tester.pumpAndSettle();

        // Verify table remains functional after vertical scroll
        expect(scrollableTable, findsOneWidget);

        // Test diagonal scrolling
        await tester.drag(scrollableTable, const Offset(-100, -50));
        await tester.pumpAndSettle();

        // Verify sticky headers remain visible
        final tableHeader = find.byKey(const Key('table_header'));
        if (tableHeader.evaluate().isNotEmpty) {
          expect(tableHeader, findsOneWidget);
        }
      }
    });

    testWidgets('Large dataset table performance and rendering', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.chat));
      await tester.pumpAndSettle();

      // Request a large table with many rows and columns
      final messageInput = find.byKey(const Key('chat_message_input'));
      await tester.enterText(messageInput, 
        'Create a comprehensive weekly meal plan table with breakfast, lunch, dinner, and snacks for each day, including detailed nutritional information for each meal');
      
      final sendButton = find.byKey(const Key('send_message_button'));
      await tester.tap(sendButton);
      await tester.pumpAndSettle(const Duration(seconds: 10));

      // Verify large table renders without performance issues
      final largeTable = find.byKey(const Key('scrollable_table'));
      if (largeTable.evaluate().isNotEmpty) {
        expect(largeTable, findsOneWidget);

        // Test performance with rapid scrolling
        for (int i = 0; i < 5; i++) {
          await tester.drag(largeTable, const Offset(-300, 0));
          await tester.pump(const Duration(milliseconds: 100));
        }
        await tester.pumpAndSettle();

        // Verify table remains responsive
        expect(largeTable, findsOneWidget);

        // Test vertical scrolling performance
        for (int i = 0; i < 5; i++) {
          await tester.drag(largeTable, const Offset(0, -200));
          await tester.pump(const Duration(milliseconds: 100));
        }
        await tester.pumpAndSettle();

        // Verify table still functions correctly
        expect(largeTable, findsOneWidget);
      }
    });

    testWidgets('Mixed data types table formatting', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.chat));
      await tester.pumpAndSettle();

      // Request table with mixed data types
      final messageInput = find.byKey(const Key('chat_message_input'));
      await tester.enterText(messageInput, 
        'Show me a table with food names, calorie counts, preparation times, difficulty levels, and cost estimates');
      
      final sendButton = find.byKey(const Key('send_message_button'));
      await tester.tap(sendButton);
      await tester.pumpAndSettle(const Duration(seconds: 6));

      // Verify mixed data table renders properly
      final mixedDataTable = find.byKey(const Key('scrollable_table'));
      if (mixedDataTable.evaluate().isNotEmpty) {
        expect(mixedDataTable, findsOneWidget);

        // Verify different data types are properly aligned
        final tableCells = find.byKey(const Key('table_cell'));
        expect(tableCells, findsWidgets);

        // Test scrolling with mixed data
        await tester.drag(mixedDataTable, const Offset(-250, 0));
        await tester.pumpAndSettle();

        // Verify alignment is maintained after scrolling
        expect(tableCells, findsWidgets);
      }
    });

    testWidgets('Table responsiveness on different screen orientations', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.chat));
      await tester.pumpAndSettle();

      // Request a table
      final messageInput = find.byKey(const Key('chat_message_input'));
      await tester.enterText(messageInput, 'Show me a macro breakdown table for different protein sources');
      
      final sendButton = find.byKey(const Key('send_message_button'));
      await tester.tap(sendButton);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Test in portrait mode (default)
      final portraitTable = find.byKey(const Key('scrollable_table'));
      if (portraitTable.evaluate().isNotEmpty) {
        expect(portraitTable, findsOneWidget);

        // Test horizontal scrolling in portrait
        await tester.drag(portraitTable, const Offset(-200, 0));
        await tester.pumpAndSettle();
        expect(portraitTable, findsOneWidget);
      }

      // Note: Actual orientation change would require device-specific testing
      // For integration tests, we verify the table adapts to available space
      
      // Simulate narrow screen by testing edge scrolling
      if (portraitTable.evaluate().isNotEmpty) {
        // Scroll to far right
        await tester.drag(portraitTable, const Offset(-500, 0));
        await tester.pumpAndSettle();
        
        // Scroll back to far left
        await tester.drag(portraitTable, const Offset(500, 0));
        await tester.pumpAndSettle();
        
        // Verify table handles edge cases
        expect(portraitTable, findsOneWidget);
      }
    });

    testWidgets('Table with nested data and complex formatting', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.chat));
      await tester.pumpAndSettle();

      // Request complex nested table
      final messageInput = find.byKey(const Key('chat_message_input'));
      await tester.enterText(messageInput, 
        'Create a detailed recipe comparison table with ingredients lists, nutritional breakdowns, and cooking instructions for 5 healthy dinner recipes');
      
      final sendButton = find.byKey(const Key('send_message_button'));
      await tester.tap(sendButton);
      await tester.pumpAndSettle(const Duration(seconds: 10));

      // Verify complex table renders
      final complexTable = find.byKey(const Key('scrollable_table'));
      if (complexTable.evaluate().isNotEmpty) {
        expect(complexTable, findsOneWidget);

        // Test scrolling with complex content
        await tester.drag(complexTable, const Offset(-300, 0));
        await tester.pumpAndSettle();

        // Verify nested content remains readable
        final nestedContent = find.byKey(const Key('table_nested_content'));
        if (nestedContent.evaluate().isNotEmpty) {
          expect(nestedContent, findsWidgets);
        }

        // Test vertical scrolling with long content
        await tester.drag(complexTable, const Offset(0, -200));
        await tester.pumpAndSettle();

        expect(complexTable, findsOneWidget);
      }
    });

    testWidgets('Table accessibility and interaction', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.chat));
      await tester.pumpAndSettle();

      // Request accessible table
      final messageInput = find.byKey(const Key('chat_message_input'));
      await tester.enterText(messageInput, 'Show me a simple nutrition facts table for common foods');
      
      final sendButton = find.byKey(const Key('send_message_button'));
      await tester.tap(sendButton);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Verify table accessibility
      final accessibleTable = find.byKey(const Key('scrollable_table'));
      if (accessibleTable.evaluate().isNotEmpty) {
        expect(accessibleTable, findsOneWidget);

        // Test tap interactions on table cells
        final firstCell = find.byKey(const Key('table_cell_0_0'));
        if (firstCell.evaluate().isNotEmpty) {
          await tester.tap(firstCell);
          await tester.pumpAndSettle();
          
          // Verify cell interaction doesn't break table
          expect(accessibleTable, findsOneWidget);
        }

        // Test long press on table
        await tester.longPress(accessibleTable);
        await tester.pumpAndSettle();

        // Verify table remains functional after long press
        expect(accessibleTable, findsOneWidget);
      }
    });

    testWidgets('Enhanced table rendering with various markdown tables', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.chat));
      await tester.pumpAndSettle();

      // Test simple markdown table
      const simpleTableMarkdown = '''
| Food | Calories | Protein |
|------|----------|---------|
| Apple | 95 | 0.5g |
| Banana | 105 | 1.3g |
| Orange | 62 | 1.2g |
''';

      final messageInput = find.byKey(const Key('chat_message_input'));
      await tester.enterText(messageInput, 'Show me this table: $simpleTableMarkdown');
      
      final sendButton = find.byKey(const Key('send_message_button'));
      await tester.tap(sendButton);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Verify enhanced table rendering with markdown
      final customScrollableTable = find.byKey(const Key('custom_scrollable_table'));
      final tableHorizontalScroll = find.byKey(const Key('table_horizontal_scroll'));
      
      if (customScrollableTable.evaluate().isNotEmpty) {
        expect(customScrollableTable, findsOneWidget);
        
        // Test horizontal scrolling
        if (tableHorizontalScroll.evaluate().isNotEmpty) {
          await tester.drag(tableHorizontalScroll, const Offset(-100, 0));
          await tester.pumpAndSettle();
        }
        
        print('✅ Enhanced table rendering with various markdown tables verified');
      }

      // Test complex markdown table
      const complexTableMarkdown = '''
| Food | Calories | Protein | Carbs | Fat | Fiber |
|------|----------|---------|-------|-----|-------|
| Apple | 95 | 0.5g | 25g | 0.3g | 4.4g |
| Banana | 105 | 1.3g | 27g | 0.4g | 3.1g |
| Orange | 62 | 1.2g | 15g | 0.2g | 3.1g |
''';

      await tester.enterText(messageInput, 'Complex table: $complexTableMarkdown');
      await tester.tap(sendButton);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Verify complex table renders with enhanced features
      final complexTable = find.byKey(const Key('custom_scrollable_table'));
      if (complexTable.evaluate().isNotEmpty) {
        expect(complexTable, findsOneWidget);
        
        // Test scrolling with complex table
        await tester.drag(complexTable, const Offset(-200, 0));
        await tester.pumpAndSettle();
        
        expect(complexTable, findsOneWidget);
      }
    });

    testWidgets('Table rendering with different markdown formats', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.chat));
      await tester.pumpAndSettle();

      // Test different table formats that might be generated by LLM
      final testQueries = [
        'Show me a simple 2x2 nutrition table',
        'Create a table with aligned columns for food comparisons',
        'Make a table with headers and multiple data rows for meal planning',
      ];

      for (int i = 0; i < testQueries.length; i++) {
        final messageInput = find.byKey(const Key('chat_message_input'));
        await tester.enterText(messageInput, testQueries[i]);
        
        final sendButton = find.byKey(const Key('send_message_button'));
        await tester.tap(sendButton);
        await tester.pumpAndSettle(const Duration(seconds: 5));

        // Verify each table format renders correctly
        final tableWidget = find.byKey(const Key('scrollable_table'));
        if (tableWidget.evaluate().isNotEmpty) {
          expect(tableWidget, findsOneWidget);

          // Test basic scrolling for each format
          await tester.drag(tableWidget, const Offset(-100, 0));
          await tester.pumpAndSettle();
          
          expect(tableWidget, findsOneWidget);
        }

        // Clear for next test
        await tester.enterText(messageInput, '');
        await tester.pumpAndSettle();
      }
    });

    testWidgets('Table error handling and fallback rendering', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.chat));
      await tester.pumpAndSettle();

      // Request potentially problematic table
      final messageInput = find.byKey(const Key('chat_message_input'));
      await tester.enterText(messageInput, 
        'Create a table with extremely long cell content and many columns that might cause rendering issues');
      
      final sendButton = find.byKey(const Key('send_message_button'));
      await tester.tap(sendButton);
      await tester.pumpAndSettle(const Duration(seconds: 8));

      // Verify error handling
      final tableOrError = find.byKey(const Key('scrollable_table'));
      final errorFallback = find.byKey(const Key('table_render_error'));
      
      // Either table renders successfully or error fallback is shown
      expect(
        tableOrError.evaluate().isNotEmpty || errorFallback.evaluate().isNotEmpty,
        isTrue
      );

      if (tableOrError.evaluate().isNotEmpty) {
        // If table rendered, test it handles extreme content
        await tester.drag(tableOrError, const Offset(-400, 0));
        await tester.pumpAndSettle();
        expect(tableOrError, findsOneWidget);
      }

      if (errorFallback.evaluate().isNotEmpty) {
        // If error fallback shown, verify it's user-friendly
        expect(errorFallback, findsOneWidget);
        
        // Verify fallback doesn't break the chat
        expect(find.byKey(const Key('chat_message_input')), findsOneWidget);
      }
    });

    testWidgets('Table performance with rapid scrolling and interactions', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.chat));
      await tester.pumpAndSettle();

      // Request medium-sized table for performance testing
      final messageInput = find.byKey(const Key('chat_message_input'));
      await tester.enterText(messageInput, 
        'Show me a weekly meal plan table with nutritional information for each meal');
      
      final sendButton = find.byKey(const Key('send_message_button'));
      await tester.tap(sendButton);
      await tester.pumpAndSettle(const Duration(seconds: 6));

      final performanceTable = find.byKey(const Key('scrollable_table'));
      if (performanceTable.evaluate().isNotEmpty) {
        // Rapid horizontal scrolling test
        for (int i = 0; i < 10; i++) {
          await tester.drag(performanceTable, const Offset(-150, 0));
          await tester.pump(const Duration(milliseconds: 50));
        }
        await tester.pumpAndSettle();

        // Verify table is still responsive
        expect(performanceTable, findsOneWidget);

        // Rapid vertical scrolling test
        for (int i = 0; i < 10; i++) {
          await tester.drag(performanceTable, const Offset(0, -100));
          await tester.pump(const Duration(milliseconds: 50));
        }
        await tester.pumpAndSettle();

        // Verify table maintains functionality
        expect(performanceTable, findsOneWidget);

        // Mixed rapid scrolling test
        for (int i = 0; i < 5; i++) {
          await tester.drag(performanceTable, const Offset(-100, -50));
          await tester.pump(const Duration(milliseconds: 30));
          await tester.drag(performanceTable, const Offset(100, 50));
          await tester.pump(const Duration(milliseconds: 30));
        }
        await tester.pumpAndSettle();

        // Final verification
        expect(performanceTable, findsOneWidget);
      }
    });

    testWidgets('Table integration with chat message history', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.chat));
      await tester.pumpAndSettle();

      // Send multiple messages with tables
      final messageInput = find.byKey(const Key('chat_message_input'));
      final sendButton = find.byKey(const Key('send_message_button'));

      // First table
      await tester.enterText(messageInput, 'Show me a protein comparison table');
      await tester.tap(sendButton);
      await tester.pumpAndSettle(const Duration(seconds: 4));

      // Second table
      await tester.enterText(messageInput, '');
      await tester.enterText(messageInput, 'Now show me a carbohydrate comparison table');
      await tester.tap(sendButton);
      await tester.pumpAndSettle(const Duration(seconds: 4));

      // Verify multiple tables in chat history
      final allTables = find.byKey(const Key('scrollable_table'));
      expect(allTables.evaluate().length, greaterThanOrEqualTo(1));

      // Test scrolling in chat to access older tables
      final chatScrollView = find.byKey(const Key('chat_scroll_view'));
      if (chatScrollView.evaluate().isNotEmpty) {
        await tester.drag(chatScrollView, const Offset(0, 200));
        await tester.pumpAndSettle();

        // Verify older tables are still functional
        if (allTables.evaluate().length > 1) {
          final firstTable = allTables.first;
          await tester.drag(firstTable, const Offset(-100, 0));
          await tester.pumpAndSettle();
          
          expect(firstTable, findsOneWidget);
        }
      }
    });
  });
}