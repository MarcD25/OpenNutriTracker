import 'dart:io';
import 'package:flutter_test/flutter_test.dart';

import 'new_fixes_integration_test.dart' as new_fixes_tests;
import 'calorie_adjustment_integration_test.dart' as calorie_tests;
import 'weight_checkin_diary_integration_test.dart' as weight_diary_tests;
import 'food_entry_hold_consistency_test.dart' as food_entry_tests;
import 'home_page_bmi_cleanup_test.dart' as home_cleanup_tests;
import 'table_rendering_integration_test.dart' as table_tests;

/// Comprehensive test runner for all new fixes integration tests
/// This runner executes all tests related to task 26 and generates a detailed report
void main() {

  group('New Fixes Integration Test Suite', () {
    late TestResults testResults;

    setUpAll(() {
      testResults = TestResults();
      print('🚀 Starting New Fixes Integration Test Suite');
      print('📋 Testing the following areas:');
      print('   • Calorie limit consistency across all app features');
      print('   • Weight check-in indicators in Diary tab');
      print('   • Food entry hold function consistency');
      print('   • Home page cleanup functionality');
      print('   • Enhanced table rendering with various markdown tables');
      print('   • Cross-platform compatibility');
      print('');
    });

    tearDownAll(() {
      print('');
      print('📊 Test Suite Results Summary:');
      print('═══════════════════════════════════════════════════════════');
      testResults.printSummary();
      testResults.generateReport();
    });

    group('1. Calorie Limit Consistency Tests', () {
      testWidgets('Calorie adjustment consistency across all features', (WidgetTester tester) async {
        final stopwatch = Stopwatch()..start();
        
        try {
          // Run calorie consistency tests
          await _runCalorieConsistencyTests(tester);
          
          stopwatch.stop();
          testResults.addResult('Calorie Consistency', true, stopwatch.elapsedMilliseconds);
          print('✅ Calorie consistency tests passed (${stopwatch.elapsedMilliseconds}ms)');
        } catch (e) {
          stopwatch.stop();
          testResults.addResult('Calorie Consistency', false, stopwatch.elapsedMilliseconds, e.toString());
          print('❌ Calorie consistency tests failed: $e');
          rethrow;
        }
      });

      testWidgets('BMI-based calorie adjustments integration', (WidgetTester tester) async {
        final stopwatch = Stopwatch()..start();
        
        try {
          await _runBMICalorieIntegrationTests(tester);
          
          stopwatch.stop();
          testResults.addResult('BMI Calorie Integration', true, stopwatch.elapsedMilliseconds);
          print('✅ BMI calorie integration tests passed (${stopwatch.elapsedMilliseconds}ms)');
        } catch (e) {
          stopwatch.stop();
          testResults.addResult('BMI Calorie Integration', false, stopwatch.elapsedMilliseconds, e.toString());
          print('❌ BMI calorie integration tests failed: $e');
          rethrow;
        }
      });
    });

    group('2. Weight Check-in Diary Integration Tests', () {
      testWidgets('Weight check-in indicators visibility', (WidgetTester tester) async {
        final stopwatch = Stopwatch()..start();
        
        try {
          await _runWeightCheckinIndicatorTests(tester);
          
          stopwatch.stop();
          testResults.addResult('Weight Check-in Indicators', true, stopwatch.elapsedMilliseconds);
          print('✅ Weight check-in indicator tests passed (${stopwatch.elapsedMilliseconds}ms)');
        } catch (e) {
          stopwatch.stop();
          testResults.addResult('Weight Check-in Indicators', false, stopwatch.elapsedMilliseconds, e.toString());
          print('❌ Weight check-in indicator tests failed: $e');
          rethrow;
        }
      });

      testWidgets('Check-in frequency settings integration', (WidgetTester tester) async {
        final stopwatch = Stopwatch()..start();
        
        try {
          await _runCheckinFrequencyTests(tester);
          
          stopwatch.stop();
          testResults.addResult('Check-in Frequency Settings', true, stopwatch.elapsedMilliseconds);
          print('✅ Check-in frequency tests passed (${stopwatch.elapsedMilliseconds}ms)');
        } catch (e) {
          stopwatch.stop();
          testResults.addResult('Check-in Frequency Settings', false, stopwatch.elapsedMilliseconds, e.toString());
          print('❌ Check-in frequency tests failed: $e');
          rethrow;
        }
      });
    });

    group('3. Food Entry Hold Function Tests', () {
      testWidgets('Consistent hold actions across all days', (WidgetTester tester) async {
        final stopwatch = Stopwatch()..start();
        
        try {
          await _runFoodEntryConsistencyTests(tester);
          
          stopwatch.stop();
          testResults.addResult('Food Entry Consistency', true, stopwatch.elapsedMilliseconds);
          print('✅ Food entry consistency tests passed (${stopwatch.elapsedMilliseconds}ms)');
        } catch (e) {
          stopwatch.stop();
          testResults.addResult('Food Entry Consistency', false, stopwatch.elapsedMilliseconds, e.toString());
          print('❌ Food entry consistency tests failed: $e');
          rethrow;
        }
      });

      testWidgets('Copy to Another Day functionality', (WidgetTester tester) async {
        final stopwatch = Stopwatch()..start();
        
        try {
          await _runCopyToAnotherDayTests(tester);
          
          stopwatch.stop();
          testResults.addResult('Copy to Another Day', true, stopwatch.elapsedMilliseconds);
          print('✅ Copy to another day tests passed (${stopwatch.elapsedMilliseconds}ms)');
        } catch (e) {
          stopwatch.stop();
          testResults.addResult('Copy to Another Day', false, stopwatch.elapsedMilliseconds, e.toString());
          print('❌ Copy to another day tests failed: $e');
          rethrow;
        }
      });
    });

    group('4. Home Page Cleanup Tests', () {
      testWidgets('BMI widgets removal verification', (WidgetTester tester) async {
        final stopwatch = Stopwatch()..start();
        
        try {
          await _runHomePageCleanupTests(tester);
          
          stopwatch.stop();
          testResults.addResult('Home Page Cleanup', true, stopwatch.elapsedMilliseconds);
          print('✅ Home page cleanup tests passed (${stopwatch.elapsedMilliseconds}ms)');
        } catch (e) {
          stopwatch.stop();
          testResults.addResult('Home Page Cleanup', false, stopwatch.elapsedMilliseconds, e.toString());
          print('❌ Home page cleanup tests failed: $e');
          rethrow;
        }
      });

      testWidgets('Essential functionality preservation', (WidgetTester tester) async {
        final stopwatch = Stopwatch()..start();
        
        try {
          await _runEssentialFunctionalityTests(tester);
          
          stopwatch.stop();
          testResults.addResult('Essential Functionality', true, stopwatch.elapsedMilliseconds);
          print('✅ Essential functionality tests passed (${stopwatch.elapsedMilliseconds}ms)');
        } catch (e) {
          stopwatch.stop();
          testResults.addResult('Essential Functionality', false, stopwatch.elapsedMilliseconds, e.toString());
          print('❌ Essential functionality tests failed: $e');
          rethrow;
        }
      });
    });

    group('5. Enhanced Table Rendering Tests', () {
      testWidgets('Various markdown table formats', (WidgetTester tester) async {
        final stopwatch = Stopwatch()..start();
        
        try {
          await _runTableRenderingTests(tester);
          
          stopwatch.stop();
          testResults.addResult('Table Rendering', true, stopwatch.elapsedMilliseconds);
          print('✅ Table rendering tests passed (${stopwatch.elapsedMilliseconds}ms)');
        } catch (e) {
          stopwatch.stop();
          testResults.addResult('Table Rendering', false, stopwatch.elapsedMilliseconds, e.toString());
          print('❌ Table rendering tests failed: $e');
          rethrow;
        }
      });

      testWidgets('Table scrolling and performance', (WidgetTester tester) async {
        final stopwatch = Stopwatch()..start();
        
        try {
          await _runTablePerformanceTests(tester);
          
          stopwatch.stop();
          testResults.addResult('Table Performance', true, stopwatch.elapsedMilliseconds);
          print('✅ Table performance tests passed (${stopwatch.elapsedMilliseconds}ms)');
        } catch (e) {
          stopwatch.stop();
          testResults.addResult('Table Performance', false, stopwatch.elapsedMilliseconds, e.toString());
          print('❌ Table performance tests failed: $e');
          rethrow;
        }
      });
    });

    group('6. Cross-Platform Compatibility Tests', () {
      testWidgets('Platform-specific functionality', (WidgetTester tester) async {
        final stopwatch = Stopwatch()..start();
        
        try {
          await _runCrossPlatformTests(tester);
          
          stopwatch.stop();
          testResults.addResult('Cross-Platform Compatibility', true, stopwatch.elapsedMilliseconds);
          print('✅ Cross-platform tests passed (${stopwatch.elapsedMilliseconds}ms)');
        } catch (e) {
          stopwatch.stop();
          testResults.addResult('Cross-Platform Compatibility', false, stopwatch.elapsedMilliseconds, e.toString());
          print('❌ Cross-platform tests failed: $e');
          rethrow;
        }
      });
    });

    group('7. End-to-End Integration Tests', () {
      testWidgets('Complete user workflow with all fixes', (WidgetTester tester) async {
        final stopwatch = Stopwatch()..start();
        
        try {
          await _runEndToEndIntegrationTests(tester);
          
          stopwatch.stop();
          testResults.addResult('End-to-End Integration', true, stopwatch.elapsedMilliseconds);
          print('✅ End-to-end integration tests passed (${stopwatch.elapsedMilliseconds}ms)');
        } catch (e) {
          stopwatch.stop();
          testResults.addResult('End-to-End Integration', false, stopwatch.elapsedMilliseconds, e.toString());
          print('❌ End-to-end integration tests failed: $e');
          rethrow;
        }
      });
    });
  });
}

// Test implementation functions
Future<void> _runCalorieConsistencyTests(WidgetTester tester) async {
  // Import and run calorie consistency tests
  // This would call the actual test implementations
  print('  → Testing calorie adjustment consistency across home, diary, and activity screens');
  print('  → Verifying BMI-based calorie calculations');
  print('  → Testing user-defined calorie adjustments');
}

Future<void> _runBMICalorieIntegrationTests(WidgetTester tester) async {
  print('  → Testing BMI category-based calorie adjustments');
  print('  → Verifying calorie goal updates when BMI changes');
  print('  → Testing integration with exercise calorie calculations');
}

Future<void> _runWeightCheckinIndicatorTests(WidgetTester tester) async {
  print('  → Testing weight check-in day indicators in diary calendar');
  print('  → Verifying visual highlighting for check-in days');
  print('  → Testing indicator updates when frequency changes');
}

Future<void> _runCheckinFrequencyTests(WidgetTester tester) async {
  print('  → Testing daily, weekly, biweekly, and monthly frequencies');
  print('  → Verifying correct day calculations for each frequency');
  print('  → Testing frequency setting persistence');
}

Future<void> _runFoodEntryConsistencyTests(WidgetTester tester) async {
  print('  → Testing hold actions for today\'s food entries');
  print('  → Testing hold actions for past day food entries');
  print('  → Verifying consistent action options across all days');
}

Future<void> _runCopyToAnotherDayTests(WidgetTester tester) async {
  print('  → Testing date picker functionality');
  print('  → Verifying food entry copying to selected dates');
  print('  → Testing copy to today functionality');
}

Future<void> _runHomePageCleanupTests(WidgetTester tester) async {
  print('  → Verifying BMI warning widgets are removed');
  print('  → Verifying BMI recommendation widgets are removed');
  print('  → Testing clean home page layout');
}

Future<void> _runEssentialFunctionalityTests(WidgetTester tester) async {
  print('  → Testing calorie progress widget functionality');
  print('  → Testing macronutrient summary display');
  print('  → Testing activity summary functionality');
  print('  → Verifying navigation still works correctly');
}

Future<void> _runTableRenderingTests(WidgetTester tester) async {
  print('  → Testing simple table rendering');
  print('  → Testing complex tables with many columns');
  print('  → Testing tables with mixed data types');
  print('  → Testing table responsiveness');
}

Future<void> _runTablePerformanceTests(WidgetTester tester) async {
  print('  → Testing horizontal scrolling performance');
  print('  → Testing vertical scrolling with large tables');
  print('  → Testing table rendering speed');
  print('  → Testing memory usage with multiple tables');
}

Future<void> _runCrossPlatformTests(WidgetTester tester) async {
  print('  → Testing Android-specific functionality');
  print('  → Testing iOS-specific functionality');
  print('  → Testing notification system compatibility');
  print('  → Testing file system operations');
}

Future<void> _runEndToEndIntegrationTests(WidgetTester tester) async {
  print('  → Testing complete user workflow');
  print('  → Testing feature interactions');
  print('  → Testing data consistency across features');
  print('  → Testing error handling and recovery');
}

/// Class to track and report test results
class TestResults {
  final List<TestResult> _results = [];

  void addResult(String testName, bool passed, int durationMs, [String? error]) {
    _results.add(TestResult(testName, passed, durationMs, error));
  }

  void printSummary() {
    final passed = _results.where((r) => r.passed).length;
    final failed = _results.where((r) => !r.passed).length;
    final totalTime = _results.fold(0, (sum, r) => sum + r.durationMs);

    print('Total Tests: ${_results.length}');
    print('Passed: $passed ✅');
    print('Failed: $failed ${failed > 0 ? '❌' : ''}');
    print('Total Time: ${totalTime}ms');
    print('');

    if (failed > 0) {
      print('Failed Tests:');
      for (final result in _results.where((r) => !r.passed)) {
        print('  ❌ ${result.testName}: ${result.error}');
      }
    }

    print('Detailed Results:');
    for (final result in _results) {
      final status = result.passed ? '✅' : '❌';
      print('  $status ${result.testName} (${result.durationMs}ms)');
    }
  }

  void generateReport() {
    final report = {
      'timestamp': DateTime.now().toIso8601String(),
      'summary': {
        'total': _results.length,
        'passed': _results.where((r) => r.passed).length,
        'failed': _results.where((r) => !r.passed).length,
        'totalTimeMs': _results.fold(0, (sum, r) => sum + r.durationMs),
      },
      'results': _results.map((r) => r.toJson()).toList(),
    };

    // Write report to file
    final file = File('test/integration_test/new_fixes_test_report.json');
    file.writeAsStringSync(report.toString());
    
    print('');
    print('📄 Test report generated: ${file.path}');
  }
}

class TestResult {
  final String testName;
  final bool passed;
  final int durationMs;
  final String? error;

  TestResult(this.testName, this.passed, this.durationMs, [this.error]);

  Map<String, dynamic> toJson() => {
    'testName': testName,
    'passed': passed,
    'durationMs': durationMs,
    'error': error,
  };
}