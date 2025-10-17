import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:opennutritracker/core/domain/exception/app_exception.dart';
import 'package:opennutritracker/features/chat/domain/entity/validation_result_entity.dart';
import 'package:opennutritracker/features/chat/presentation/widgets/validation_feedback_widget.dart';

void main() {
  group('ValidationFeedbackWidget', () {
    testWidgets('should not show anything for valid response without debug', (WidgetTester tester) async {
      const validationResult = ValidationResult(
        isValid: true,
        issues: [],
        severity: ValidationSeverity.info,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ValidationFeedbackWidget(
              validationResult: validationResult,
              showDebugInfo: false,
            ),
          ),
        ),
      );

      expect(find.byType(ValidationFeedbackWidget), findsOneWidget);
      expect(find.text('Response validated'), findsNothing);
    });

    testWidgets('should show validation indicator for invalid response', (WidgetTester tester) async {
      const validationResult = ValidationResult(
        isValid: false,
        issues: [ValidationIssue.responseTooLarge],
        severity: ValidationSeverity.warning,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ValidationFeedbackWidget(
              validationResult: validationResult,
              showDebugInfo: false,
            ),
          ),
        ),
      );

      expect(find.text('Minor quality concerns'), findsOneWidget);
      expect(find.byIcon(Icons.info_outline), findsOneWidget);
    });

    testWidgets('should show retry button for critical validation failure', (WidgetTester tester) async {
      bool retryPressed = false;
      const validationResult = ValidationResult(
        isValid: false,
        issues: [ValidationIssue.incompleteResponse],
        severity: ValidationSeverity.critical,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ValidationFeedbackWidget(
              validationResult: validationResult,
              onRetry: () => retryPressed = true,
              showDebugInfo: false,
            ),
          ),
        ),
      );

      expect(find.text('Critical validation issues'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);

      await tester.tap(find.text('Retry'));
      await tester.pump();

      expect(retryPressed, isTrue);
    });

    testWidgets('should show debug information when enabled', (WidgetTester tester) async {
      const validationResult = ValidationResult(
        isValid: true,
        issues: [],
        severity: ValidationSeverity.info,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ValidationFeedbackWidget(
              validationResult: validationResult,
              showDebugInfo: true,
            ),
          ),
        ),
      );

      expect(find.text('Response validated'), findsOneWidget);
      expect(find.text('Debug Information:'), findsOneWidget);
      expect(find.textContaining('Has Corrected Response'), findsOneWidget);
    });

    testWidgets('should expand to show issue details when tapped', (WidgetTester tester) async {
      const validationResult = ValidationResult(
        isValid: false,
        issues: [ValidationIssue.unrealisticCalories, ValidationIssue.missingNutritionInfo],
        severity: ValidationSeverity.error,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ValidationFeedbackWidget(
              validationResult: validationResult,
              showDebugInfo: false,
            ),
          ),
        ),
      );

      // Initially collapsed
      expect(find.text('Issues Found:'), findsNothing);

      // Tap to expand
      await tester.tap(find.byIcon(Icons.expand_more));
      await tester.pump();

      // Now expanded
      expect(find.text('Issues Found:'), findsOneWidget);
      expect(find.text('Calorie values appear unrealistic or outside expected ranges'), findsOneWidget);
      expect(find.text('Required nutrition information is missing from the response'), findsOneWidget);
    });

    testWidgets('should display correct severity colors and icons', (WidgetTester tester) async {
      const criticalResult = ValidationResult(
        isValid: false,
        issues: [ValidationIssue.incompleteResponse],
        severity: ValidationSeverity.critical,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ValidationFeedbackWidget(
              validationResult: criticalResult,
              showDebugInfo: false,
            ),
          ),
        ),
      );

      expect(find.text('Critical validation issues'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('should handle all validation issue types', (WidgetTester tester) async {
      const validationResult = ValidationResult(
        isValid: false,
        issues: [
          ValidationIssue.responseTooLarge,
          ValidationIssue.missingNutritionInfo,
          ValidationIssue.unrealisticCalories,
          ValidationIssue.incompleteResponse,
          ValidationIssue.formatError,
        ],
        severity: ValidationSeverity.error,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ValidationFeedbackWidget(
              validationResult: validationResult,
              showDebugInfo: false,
            ),
          ),
        ),
      );

      // Expand to see all issues
      await tester.tap(find.byIcon(Icons.expand_more));
      await tester.pump();

      expect(find.text('Response is unusually long and may contain excessive information'), findsOneWidget);
      expect(find.text('Required nutrition information is missing from the response'), findsOneWidget);
      expect(find.text('Calorie values appear unrealistic or outside expected ranges'), findsOneWidget);
      expect(find.text('Response appears to be incomplete or cut off'), findsOneWidget);
      expect(find.text('Response format does not match expected structure'), findsOneWidget);
    });

    testWidgets('should show validation summary with correct status', (WidgetTester tester) async {
      const validationResult = ValidationResult(
        isValid: false,
        issues: [ValidationIssue.formatError],
        severity: ValidationSeverity.warning,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ValidationFeedbackWidget(
              validationResult: validationResult,
              showDebugInfo: false,
            ),
          ),
        ),
      );

      // Expand to see details
      await tester.tap(find.byIcon(Icons.expand_more));
      await tester.pump();

      expect(find.text('Status: Invalid'), findsOneWidget);
      expect(find.text('Severity: WARNING'), findsOneWidget);
      expect(find.byIcon(Icons.cancel), findsOneWidget);
    });

    testWidgets('should show validation summary for valid response', (WidgetTester tester) async {
      const validationResult = ValidationResult(
        isValid: true,
        issues: [],
        severity: ValidationSeverity.info,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ValidationFeedbackWidget(
              validationResult: validationResult,
              showDebugInfo: true,
            ),
          ),
        ),
      );

      expect(find.text('Status: Valid'), findsOneWidget);
      expect(find.text('Severity: INFO'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('should display debug information correctly', (WidgetTester tester) async {
      const validationResult = ValidationResult(
        isValid: false,
        issues: [ValidationIssue.formatError],
        severity: ValidationSeverity.error,
        correctedResponse: 'Corrected response text',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ValidationFeedbackWidget(
              validationResult: validationResult,
              showDebugInfo: true,
            ),
          ),
        ),
      );

      expect(find.text('Debug Information:'), findsOneWidget);
      expect(find.text('Has Corrected Response: Yes'), findsOneWidget);
      expect(find.text('Issue Count: 1'), findsOneWidget);
      expect(find.textContaining('Validation Time:'), findsOneWidget);
    });

    testWidgets('should handle corrected response indicator', (WidgetTester tester) async {
      const validationResultWithoutCorrection = ValidationResult(
        isValid: false,
        issues: [ValidationIssue.formatError],
        severity: ValidationSeverity.error,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ValidationFeedbackWidget(
              validationResult: validationResultWithoutCorrection,
              showDebugInfo: true,
            ),
          ),
        ),
      );

      expect(find.text('Has Corrected Response: No'), findsOneWidget);
    });

    testWidgets('should collapse when expand icon is tapped again', (WidgetTester tester) async {
      const validationResult = ValidationResult(
        isValid: false,
        issues: [ValidationIssue.unrealisticCalories],
        severity: ValidationSeverity.warning,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ValidationFeedbackWidget(
              validationResult: validationResult,
              showDebugInfo: false,
            ),
          ),
        ),
      );

      // Initially collapsed
      expect(find.text('Issues Found:'), findsNothing);

      // Expand
      await tester.tap(find.byIcon(Icons.expand_more));
      await tester.pump();
      expect(find.text('Issues Found:'), findsOneWidget);

      // Collapse again
      await tester.tap(find.byIcon(Icons.expand_less));
      await tester.pump();
      expect(find.text('Issues Found:'), findsNothing);
    });

    testWidgets('should show retry button only for invalid responses with onRetry callback', (WidgetTester tester) async {
      const validationResult = ValidationResult(
        isValid: false,
        issues: [ValidationIssue.incompleteResponse],
        severity: ValidationSeverity.error,
      );

      // Test without onRetry callback
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ValidationFeedbackWidget(
              validationResult: validationResult,
              showDebugInfo: false,
            ),
          ),
        ),
      );

      expect(find.text('Retry'), findsNothing);

      // Test with onRetry callback
      bool retryPressed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ValidationFeedbackWidget(
              validationResult: validationResult,
              onRetry: () => retryPressed = true,
              showDebugInfo: false,
            ),
          ),
        ),
      );

      expect(find.text('Retry'), findsOneWidget);

      await tester.tap(find.text('Retry'));
      await tester.pump();

      expect(retryPressed, isTrue);
    });

    testWidgets('should not show retry button for valid responses', (WidgetTester tester) async {
      const validationResult = ValidationResult(
        isValid: true,
        issues: [],
        severity: ValidationSeverity.info,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ValidationFeedbackWidget(
              validationResult: validationResult,
              onRetry: () {},
              showDebugInfo: true,
            ),
          ),
        ),
      );

      expect(find.text('Retry'), findsNothing);
    });
  });
}