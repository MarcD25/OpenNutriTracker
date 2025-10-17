import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:opennutritracker/core/domain/exception/app_exception.dart';
import 'package:opennutritracker/core/presentation/widgets/error_display_widget.dart';

void main() {
  group('ErrorDisplayWidget', () {
    testWidgets('should display validation error with critical severity', (tester) async {
      const error = ValidationException(
        'Critical validation error',
        ValidationSeverity.critical,
        [ValidationIssue.unrealisticCalories, ValidationIssue.missingRequiredData],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorDisplayWidget(
              error: error,
              onRetry: () {},
              onDismiss: () {},
            ),
          ),
        ),
      );

      // Check that the error message is displayed
      expect(find.text('Critical validation error'), findsOneWidget);
      
      // Check that the critical error title is displayed
      expect(find.text('Critical Error'), findsOneWidget);
      
      // Check that the error icon is displayed
      expect(find.byIcon(Icons.error), findsOneWidget);
      
      // Check that issues are displayed
      expect(find.text('Issues:'), findsOneWidget);
      expect(find.textContaining('Calorie values are outside realistic range'), findsOneWidget);
      expect(find.textContaining('Required data is missing'), findsOneWidget);
      
      // Check that action buttons are displayed
      expect(find.text('Retry'), findsOneWidget);
      expect(find.text('Recovery Options'), findsOneWidget);
      expect(find.text('Dismiss'), findsOneWidget);
    });

    testWidgets('should display validation error with warning severity', (tester) async {
      const error = ValidationException(
        'Warning validation error',
        ValidationSeverity.warning,
        [ValidationIssue.responseTooLarge],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorDisplayWidget(
              error: error,
              showRecoveryOptions: false,
            ),
          ),
        ),
      );

      // Check that the warning title is displayed
      expect(find.text('Warning'), findsOneWidget);
      
      // Check that the warning icon is displayed
      expect(find.byIcon(Icons.info), findsOneWidget);
      
      // Check that recovery options button is not displayed
      expect(find.text('Recovery Options'), findsNothing);
    });

    testWidgets('should display error code when showDetails is true', (tester) async {
      const error = ValidationException(
        'Error with code',
        ValidationSeverity.error,
        [ValidationIssue.formatError],
        code: 'ERR_001',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorDisplayWidget(
              error: error,
              showDetails: true,
            ),
          ),
        ),
      );

      // Check that the error code is displayed
      expect(find.textContaining('Error Code: ERR_001'), findsOneWidget);
    });

    testWidgets('should handle non-validation errors', (tester) async {
      const error = LogisticsException('Logistics tracking failed');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorDisplayWidget(error: error),
          ),
        ),
      );

      // Check that the error message is displayed
      expect(find.text('Logistics tracking failed'), findsOneWidget);
      
      // Check that the generic error title is displayed
      expect(find.text('Error'), findsOneWidget);
      
      // Check that issues section is not displayed for non-validation errors
      expect(find.text('Issues:'), findsNothing);
    });

    testWidgets('should call onRetry when retry button is tapped', (tester) async {
      bool retryCallbackCalled = false;
      const error = ValidationException(
        'Test error',
        ValidationSeverity.error,
        [ValidationIssue.formatError],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorDisplayWidget(
              error: error,
              onRetry: () {
                retryCallbackCalled = true;
              },
            ),
          ),
        ),
      );

      // Tap the retry button
      await tester.tap(find.text('Retry'));
      await tester.pump();

      expect(retryCallbackCalled, isTrue);
    });

    testWidgets('should call onDismiss when dismiss button is tapped', (tester) async {
      bool dismissCallbackCalled = false;
      const error = ValidationException(
        'Test error',
        ValidationSeverity.error,
        [ValidationIssue.formatError],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorDisplayWidget(
              error: error,
              onDismiss: () {
                dismissCallbackCalled = true;
              },
            ),
          ),
        ),
      );

      // Tap the dismiss button
      await tester.tap(find.text('Dismiss'));
      await tester.pump();

      expect(dismissCallbackCalled, isTrue);
    });
  });

  group('CompactErrorWidget', () {
    testWidgets('should display compact error message', (tester) async {
      const error = ValidationException(
        'Compact error message',
        ValidationSeverity.error,
        [ValidationIssue.formatError],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CompactErrorWidget(error: error),
          ),
        ),
      );

      // Check that the error message is displayed
      expect(find.text('Compact error message'), findsOneWidget);
      
      // Check that the error icon is displayed
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('should show retry and dismiss buttons when callbacks provided', (tester) async {
      const error = ValidationException(
        'Test error',
        ValidationSeverity.error,
        [ValidationIssue.formatError],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CompactErrorWidget(
              error: error,
              onRetry: () {},
              onDismiss: () {},
            ),
          ),
        ),
      );

      // Check that action buttons are displayed
      expect(find.byIcon(Icons.refresh), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);
    });
  });

  group('ErrorBannerWidget', () {
    testWidgets('should display error banner when visible', (tester) async {
      const error = ValidationException(
        'Banner error message',
        ValidationSeverity.error,
        [ValidationIssue.formatError],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorBannerWidget(
              error: error,
              isVisible: true,
              onDismiss: () {},
            ),
          ),
        ),
      );

      // Check that the error message is displayed
      expect(find.text('Banner error message'), findsOneWidget);
      
      // Check that the error title is displayed
      expect(find.text('Error'), findsOneWidget);
      
      // Check that the close button is displayed
      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('should not display error banner when not visible', (tester) async {
      const error = ValidationException(
        'Banner error message',
        ValidationSeverity.error,
        [ValidationIssue.formatError],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorBannerWidget(
              error: error,
              isVisible: false,
              onDismiss: () {},
            ),
          ),
        ),
      );

      // Check that the error message is not displayed
      expect(find.text('Banner error message'), findsNothing);
    });

    testWidgets('should call onDismiss when close button is tapped', (tester) async {
      bool dismissCallbackCalled = false;
      const error = ValidationException(
        'Test error',
        ValidationSeverity.error,
        [ValidationIssue.formatError],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorBannerWidget(
              error: error,
              isVisible: true,
              onDismiss: () {
                dismissCallbackCalled = true;
              },
            ),
          ),
        ),
      );

      // Tap the close button
      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();

      expect(dismissCallbackCalled, isTrue);
    });

    testWidgets('should show retry button when onRetry is provided', (tester) async {
      const error = ValidationException(
        'Test error',
        ValidationSeverity.error,
        [ValidationIssue.formatError],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ErrorBannerWidget(
              error: error,
              isVisible: true,
              onRetry: () {},
              onDismiss: () {},
            ),
          ),
        ),
      );

      // Check that the retry button is displayed
      expect(find.text('Retry'), findsOneWidget);
    });
  });
}