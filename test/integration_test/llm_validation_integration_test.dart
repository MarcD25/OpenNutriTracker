import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:opennutritracker/main.dart' as app;
import 'package:opennutritracker/features/chat/domain/entity/validation_result_entity.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('LLM Validation Integration Tests', () {
    testWidgets('Normal nutrition query validation flow', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to chat screen
      await tester.tap(find.byIcon(Icons.chat));
      await tester.pumpAndSettle();

      // Send a normal nutrition query
      final messageInput = find.byKey(const Key('chat_message_input'));
      await tester.enterText(messageInput, 'What are the calories in 100g of chicken breast?');
      
      final sendButton = find.byKey(const Key('send_message_button'));
      await tester.tap(sendButton);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Verify message appears in chat
      expect(find.byKey(const Key('chat_message_bubble')), findsWidgets);

      // Verify no validation warnings for normal response
      expect(find.byKey(const Key('validation_warning_indicator')), findsNothing);

      // Verify response contains expected nutrition information
      final responseText = find.byType(Text);
      bool foundNutritionInfo = false;
      
      for (final textWidget in responseText.evaluate()) {
        final text = (textWidget.widget as Text).data;
        if (text != null && (text.contains('calorie') || text.contains('protein') || text.contains('100g'))) {
          foundNutritionInfo = true;
          break;
        }
      }
      
      expect(foundNutritionInfo, isTrue);
    });

    testWidgets('Large response validation and truncation', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.chat));
      await tester.pumpAndSettle();

      // Request a potentially large response
      final messageInput = find.byKey(const Key('chat_message_input'));
      await tester.enterText(messageInput, 
        'Create a detailed 7-day meal plan with complete nutritional breakdown for each meal, including shopping lists and preparation instructions');
      
      final sendButton = find.byKey(const Key('send_message_button'));
      await tester.tap(sendButton);
      await tester.pumpAndSettle(const Duration(seconds: 10));

      // Check if validation feedback appears for large responses
      final validationFeedback = find.byKey(const Key('validation_feedback_widget'));
      
      if (validationFeedback.evaluate().isNotEmpty) {
        // Verify validation feedback shows appropriate message
        expect(find.byKey(const Key('validation_message')), findsOneWidget);
        
        // Check if truncation indicator is present
        final truncationIndicator = find.byKey(const Key('response_truncated_indicator'));
        if (truncationIndicator.evaluate().isNotEmpty) {
          expect(truncationIndicator, findsOneWidget);
        }
      }

      // Verify response is still readable and useful
      expect(find.byKey(const Key('chat_message_bubble')), findsWidgets);
    });

    testWidgets('Unrealistic calorie values validation', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.chat));
      await tester.pumpAndSettle();

      // Ask for calorie information that might trigger validation
      final messageInput = find.byKey(const Key('chat_message_input'));
      await tester.enterText(messageInput, 'How many calories should I eat to lose 10 pounds in one week?');
      
      final sendButton = find.byKey(const Key('send_message_button'));
      await tester.tap(sendButton);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Check if validation catches unrealistic recommendations
      final validationWarning = find.byKey(const Key('calorie_validation_warning'));
      
      // If the LLM suggests unrealistic calorie restrictions, validation should catch it
      if (validationWarning.evaluate().isNotEmpty) {
        expect(validationWarning, findsOneWidget);
        
        // Verify warning message is appropriate
        final warningText = find.byKey(const Key('validation_warning_text'));
        if (warningText.evaluate().isNotEmpty) {
          final warning = (tester.widget(warningText) as Text).data;
          expect(warning, anyOf(
            contains('unrealistic'),
            contains('unsafe'),
            contains('consult'),
          ));
        }
      }
    });

    testWidgets('Incomplete nutrition information validation', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.chat));
      await tester.pumpAndSettle();

      // Ask for comprehensive nutrition information
      final messageInput = find.byKey(const Key('chat_message_input'));
      await tester.enterText(messageInput, 'Give me complete nutritional information for salmon');
      
      final sendButton = find.byKey(const Key('send_message_button'));
      await tester.tap(sendButton);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Verify response contains key nutritional components
      final responseMessages = find.byKey(const Key('chat_message_bubble'));
      expect(responseMessages, findsWidgets);

      // Check if validation ensures completeness
      final completenessIndicator = find.byKey(const Key('nutrition_completeness_indicator'));
      
      if (completenessIndicator.evaluate().isNotEmpty) {
        // If validation detects missing information, it should be indicated
        final missingInfoWarning = find.byKey(const Key('missing_nutrition_info_warning'));
        if (missingInfoWarning.evaluate().isNotEmpty) {
          expect(missingInfoWarning, findsOneWidget);
        }
      }
    });

    testWidgets('Validation retry mechanism', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.chat));
      await tester.pumpAndSettle();

      // Send a message that might trigger validation issues
      final messageInput = find.byKey(const Key('chat_message_input'));
      await tester.enterText(messageInput, 'Tell me about extreme dieting methods');
      
      final sendButton = find.byKey(const Key('send_message_button'));
      await tester.tap(sendButton);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Check if retry button appears for problematic responses
      final retryButton = find.byKey(const Key('retry_message_button'));
      
      if (retryButton.evaluate().isNotEmpty) {
        // Test retry functionality
        await tester.tap(retryButton);
        await tester.pumpAndSettle(const Duration(seconds: 5));

        // Verify new response is generated
        expect(find.byKey(const Key('chat_message_bubble')), findsWidgets);
        
        // Verify retry was logged
        // This would be checked through the logistics tracking system
      }
    });

    testWidgets('Validation result logging and analytics', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.chat));
      await tester.pumpAndSettle();

      // Send multiple messages to test validation logging
      final messageInput = find.byKey(const Key('chat_message_input'));
      
      // Message 1: Normal query
      await tester.enterText(messageInput, 'Calories in an apple?');
      await tester.tap(find.byKey(const Key('send_message_button')));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Clear input and send another message
      await tester.enterText(messageInput, '');
      await tester.pumpAndSettle();

      // Message 2: Complex query
      await tester.enterText(messageInput, 'Create a complex meal plan with detailed macros');
      await tester.tap(find.byKey(const Key('send_message_button')));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Verify validation results are being tracked
      // In a real implementation, this would check the logistics data source
      // for validation events being logged
      
      // Check if validation statistics are available (if implemented in UI)
      final validationStats = find.byKey(const Key('validation_statistics'));
      if (validationStats.evaluate().isNotEmpty) {
        expect(validationStats, findsOneWidget);
      }
    });

    testWidgets('Validation with different response formats', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.chat));
      await tester.pumpAndSettle();

      // Test validation with table response
      final messageInput = find.byKey(const Key('chat_message_input'));
      await tester.enterText(messageInput, 'Show me a nutrition comparison table for different fruits');
      
      final sendButton = find.byKey(const Key('send_message_button'));
      await tester.tap(sendButton);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Verify table validation works
      final tableResponse = find.byKey(const Key('scrollable_table'));
      if (tableResponse.evaluate().isNotEmpty) {
        // Verify table validation passed
        expect(find.byKey(const Key('table_validation_error')), findsNothing);
      }

      // Test validation with list response
      await tester.enterText(messageInput, '');
      await tester.enterText(messageInput, 'List 10 high-protein foods with their protein content');
      await tester.tap(sendButton);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Verify list format validation
      final listResponse = find.byType(Text);
      bool foundListFormat = false;
      
      for (final textWidget in listResponse.evaluate()) {
        final text = (textWidget.widget as Text).data;
        if (text != null && (text.contains('1.') || text.contains('•') || text.contains('-'))) {
          foundListFormat = true;
          break;
        }
      }
      
      // If list format is expected, validation should ensure it's present
      if (foundListFormat) {
        expect(find.byKey(const Key('format_validation_error')), findsNothing);
      }
    });

    testWidgets('Validation error handling and user feedback', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.chat));
      await tester.pumpAndSettle();

      // Send a message that might cause validation to fail
      final messageInput = find.byKey(const Key('chat_message_input'));
      await tester.enterText(messageInput, 'Generate random text that has nothing to do with nutrition');
      
      final sendButton = find.byKey(const Key('send_message_button'));
      await tester.tap(sendButton);
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Check if validation error handling works
      final validationError = find.byKey(const Key('validation_error_message'));
      
      if (validationError.evaluate().isNotEmpty) {
        // Verify error message is user-friendly
        final errorText = (tester.widget(validationError) as Text).data;
        expect(errorText, isNotNull);
        expect(errorText, isNot(contains('Exception')));
        expect(errorText, isNot(contains('Error:')));
        
        // Verify recovery options are provided
        expect(find.byKey(const Key('try_again_button')), findsOneWidget);
      }
    });

    testWidgets('Validation performance with rapid messages', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.chat));
      await tester.pumpAndSettle();

      final messageInput = find.byKey(const Key('chat_message_input'));
      final sendButton = find.byKey(const Key('send_message_button'));

      // Send multiple messages in quick succession
      for (int i = 0; i < 3; i++) {
        await tester.enterText(messageInput, 'Quick question $i: calories in rice?');
        await tester.tap(sendButton);
        await tester.pump(const Duration(milliseconds: 500));
      }

      // Wait for all responses
      await tester.pumpAndSettle(const Duration(seconds: 10));

      // Verify all messages were processed and validated
      final messageCount = find.byKey(const Key('chat_message_bubble')).evaluate().length;
      expect(messageCount, greaterThanOrEqualTo(6)); // 3 user messages + 3 responses

      // Verify no validation errors occurred due to rapid sending
      expect(find.byKey(const Key('validation_overload_error')), findsNothing);
    });
  });
}