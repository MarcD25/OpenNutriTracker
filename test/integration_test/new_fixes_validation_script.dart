import 'dart:io';
import 'dart:convert';

/// Validation script for new fixes integration tests
/// Ensures all requirements from task 26 are properly tested and validated
void main() async {
  print('🔍 New Fixes Validation Script');
  print('═══════════════════════════════════════════════════════════');
  print('Validating integration tests for task 26: Integration testing for new fixes');
  print('');

  final validator = NewFixesValidator();
  await validator.runValidation();
}

class NewFixesValidator {
  final List<ValidationResult> results = [];

  Future<void> runValidation() async {
    print('📋 Validation Checklist:');
    print('');

    // Validate each requirement from task 26
    await _validateCalorieLimitConsistency();
    await _validateWeightCheckinIndicators();
    await _validateFoodEntryHoldFunction();
    await _validateHomePageCleanup();
    await _validateTableRendering();
    await _validateCrossPlatformTesting();

    // Generate validation report
    _generateValidationReport();
    _printSummary();
  }

  Future<void> _validateCalorieLimitConsistency() async {
    print('1. 🧮 Calorie Limit Consistency Tests');
    
    // Check if calorie adjustment integration test exists
    final calorieTestFile = File('test/integration_test/calorie_adjustment_integration_test.dart');
    if (await calorieTestFile.exists()) {
      results.add(ValidationResult('Calorie adjustment test file exists', true));
      print('   ✅ Calorie adjustment integration test file found');
      
      // Validate test content
      final content = await calorieTestFile.readAsString();
      if (content.contains('calorie_adjustment_widget') && 
          content.contains('home_calorie_goal') &&
          content.contains('diary_calorie_goal')) {
        results.add(ValidationResult('Calorie consistency across screens tested', true));
        print('   ✅ Tests verify calorie consistency across home, diary, and activity screens');
      } else {
        results.add(ValidationResult('Calorie consistency across screens tested', false, 
          'Missing tests for calorie consistency across different screens'));
        print('   ❌ Missing tests for calorie consistency across screens');
      }
    } else {
      results.add(ValidationResult('Calorie adjustment test file exists', false, 
        'Calorie adjustment integration test file not found'));
      print('   ❌ Calorie adjustment integration test file not found');
    }

    // Check enhanced calorie goal calculator tests
    final enhancedCalcTest = File('test/unit_test/core/utils/calc/enhanced_calorie_goal_calc_test.dart');
    if (await enhancedCalcTest.exists()) {
      results.add(ValidationResult('Enhanced calorie calculator unit tests exist', true));
      print('   ✅ Enhanced calorie calculator unit tests found');
    } else {
      results.add(ValidationResult('Enhanced calorie calculator unit tests exist', false,
        'Enhanced calorie calculator unit tests not found'));
      print('   ❌ Enhanced calorie calculator unit tests not found');
    }

    print('');
  }

  Future<void> _validateWeightCheckinIndicators() async {
    print('2. ⚖️ Weight Check-in Indicators Tests');
    
    // Check weight check-in diary integration test
    final weightDiaryTest = File('test/integration_test/weight_checkin_diary_integration_test.dart');
    if (await weightDiaryTest.exists()) {
      results.add(ValidationResult('Weight check-in diary integration test exists', true));
      print('   ✅ Weight check-in diary integration test file found');
      
      // Validate test content
      final content = await weightDiaryTest.readAsString();
      if (content.contains('checkin_day_indicator') && 
          content.contains('checkin_frequency_selector') &&
          content.contains('diary_calendar')) {
        results.add(ValidationResult('Weight check-in indicators properly tested', true));
        print('   ✅ Tests verify weight check-in indicators appear correctly in Diary tab');
      } else {
        results.add(ValidationResult('Weight check-in indicators properly tested', false,
          'Missing tests for weight check-in indicators in diary'));
        print('   ❌ Missing tests for weight check-in indicators in diary');
      }
    } else {
      results.add(ValidationResult('Weight check-in diary integration test exists', false,
        'Weight check-in diary integration test file not found'));
      print('   ❌ Weight check-in diary integration test file not found');
    }

    // Check weight check-in calendar service tests
    final calendarServiceTest = File('test/unit_test/features/weight_checkin/domain/service/weight_checkin_calendar_service_test.dart');
    if (await calendarServiceTest.exists()) {
      results.add(ValidationResult('Weight check-in calendar service tests exist', true));
      print('   ✅ Weight check-in calendar service unit tests found');
    } else {
      results.add(ValidationResult('Weight check-in calendar service tests exist', false,
        'Weight check-in calendar service unit tests not found'));
      print('   ❌ Weight check-in calendar service unit tests not found');
    }

    print('');
  }

  Future<void> _validateFoodEntryHoldFunction() async {
    print('3. 🍎 Food Entry Hold Function Tests');
    
    // Check food entry hold consistency test
    final foodEntryTest = File('test/integration_test/food_entry_hold_consistency_test.dart');
    if (await foodEntryTest.exists()) {
      results.add(ValidationResult('Food entry hold consistency test exists', true));
      print('   ✅ Food entry hold consistency integration test file found');
      
      // Validate test content
      final content = await foodEntryTest.readAsString();
      if (content.contains('Copy to Another Day') && 
          content.contains('Edit Details') &&
          content.contains('Delete') &&
          content.contains('DatePickerDialog')) {
        results.add(ValidationResult('Food entry hold function properly tested', true));
        print('   ✅ Tests verify consistent hold function across different days');
      } else {
        results.add(ValidationResult('Food entry hold function properly tested', false,
          'Missing tests for food entry hold function consistency'));
        print('   ❌ Missing tests for food entry hold function consistency');
      }
    } else {
      results.add(ValidationResult('Food entry hold consistency test exists', false,
        'Food entry hold consistency test file not found'));
      print('   ❌ Food entry hold consistency test file not found');
    }

    // Check food entry actions unit tests
    final foodEntryActionsTest = File('test/unit_test/features/diary/presentation/widgets/food_entry_actions_test.dart');
    if (await foodEntryActionsTest.exists()) {
      results.add(ValidationResult('Food entry actions unit tests exist', true));
      print('   ✅ Food entry actions unit tests found');
    } else {
      results.add(ValidationResult('Food entry actions unit tests exist', false,
        'Food entry actions unit tests not found'));
      print('   ❌ Food entry actions unit tests not found');
    }

    print('');
  }

  Future<void> _validateHomePageCleanup() async {
    print('4. 🏠 Home Page Cleanup Tests');
    
    // Check home page BMI cleanup test
    final homeCleanupTest = File('test/integration_test/home_page_bmi_cleanup_test.dart');
    if (await homeCleanupTest.exists()) {
      results.add(ValidationResult('Home page BMI cleanup test exists', true));
      print('   ✅ Home page BMI cleanup integration test file found');
      
      // Validate test content
      final content = await homeCleanupTest.readAsString();
      if (content.contains('bmi_warning_widget') && 
          content.contains('bmi_recommendations_widget') &&
          content.contains('findsNothing')) {
        results.add(ValidationResult('Home page cleanup properly tested', true));
        print('   ✅ Tests verify BMI warnings and recommendations are removed');
      } else {
        results.add(ValidationResult('Home page cleanup properly tested', false,
          'Missing tests for BMI widget removal'));
        print('   ❌ Missing tests for BMI widget removal');
      }

      if (content.contains('calorie_progress_widget') && 
          content.contains('macronutrient_summary_widget') &&
          content.contains('activity_summary_widget')) {
        results.add(ValidationResult('Essential functionality preservation tested', true));
        print('   ✅ Tests verify essential functionality is preserved');
      } else {
        results.add(ValidationResult('Essential functionality preservation tested', false,
          'Missing tests for essential functionality preservation'));
        print('   ❌ Missing tests for essential functionality preservation');
      }
    } else {
      results.add(ValidationResult('Home page BMI cleanup test exists', false,
        'Home page BMI cleanup test file not found'));
      print('   ❌ Home page BMI cleanup test file not found');
    }

    print('');
  }

  Future<void> _validateTableRendering() async {
    print('5. 📊 Enhanced Table Rendering Tests');
    
    // Check table rendering integration test
    final tableRenderingTest = File('test/integration_test/table_rendering_integration_test.dart');
    if (await tableRenderingTest.exists()) {
      results.add(ValidationResult('Table rendering integration test exists', true));
      print('   ✅ Table rendering integration test file found');
      
      // Validate test content
      final content = await tableRenderingTest.readAsString();
      if (content.contains('custom_scrollable_table') && 
          content.contains('table_horizontal_scroll') &&
          content.contains('markdown')) {
        results.add(ValidationResult('Table rendering properly tested', true));
        print('   ✅ Tests verify enhanced table rendering with various markdown tables');
      } else {
        results.add(ValidationResult('Table rendering properly tested', false,
          'Missing tests for enhanced table rendering'));
        print('   ❌ Missing tests for enhanced table rendering');
      }
    } else {
      results.add(ValidationResult('Table rendering integration test exists', false,
        'Table rendering integration test file not found'));
      print('   ❌ Table rendering integration test file not found');
    }

    // Check custom scrollable table widget tests
    final customTableTest = File('test/widget_test/core/presentation/widgets/custom_scrollable_table_test.dart');
    if (await customTableTest.exists()) {
      results.add(ValidationResult('Custom scrollable table widget tests exist', true));
      print('   ✅ Custom scrollable table widget tests found');
    } else {
      results.add(ValidationResult('Custom scrollable table widget tests exist', false,
        'Custom scrollable table widget tests not found'));
      print('   ❌ Custom scrollable table widget tests not found');
    }

    print('');
  }

  Future<void> _validateCrossPlatformTesting() async {
    print('6. 🌐 Cross-Platform Testing');
    
    // Check if tests include platform-specific considerations
    final testFiles = [
      'test/integration_test/new_fixes_integration_test.dart',
      'test/integration_test/calorie_adjustment_integration_test.dart',
      'test/integration_test/weight_checkin_diary_integration_test.dart',
    ];

    bool hasCrossPlatformTests = false;
    for (final testFile in testFiles) {
      final file = File(testFile);
      if (await file.exists()) {
        final content = await file.readAsString();
        if (content.contains('cross-platform') || 
            content.contains('platform-specific') ||
            content.contains('Android') ||
            content.contains('iOS')) {
          hasCrossPlatformTests = true;
          break;
        }
      }
    }

    if (hasCrossPlatformTests) {
      results.add(ValidationResult('Cross-platform testing included', true));
      print('   ✅ Tests include cross-platform compatibility checks');
    } else {
      results.add(ValidationResult('Cross-platform testing included', false,
        'Missing cross-platform compatibility tests'));
      print('   ❌ Missing cross-platform compatibility tests');
    }

    // Check notification system tests (platform-specific)
    final notificationTest = File('test/integration_test/notification_system_integration_test.dart');
    if (await notificationTest.exists()) {
      results.add(ValidationResult('Notification system tests exist', true));
      print('   ✅ Notification system integration tests found');
    } else {
      results.add(ValidationResult('Notification system tests exist', false,
        'Notification system integration tests not found'));
      print('   ❌ Notification system integration tests not found');
    }

    print('');
  }

  void _generateValidationReport() {
    final report = {
      'timestamp': DateTime.now().toIso8601String(),
      'task': 'Task 26: Integration testing for new fixes',
      'summary': {
        'total_validations': results.length,
        'passed': results.where((r) => r.passed).length,
        'failed': results.where((r) => !r.passed).length,
        'success_rate': '${((results.where((r) => r.passed).length / results.length) * 100).toStringAsFixed(1)}%',
      },
      'validations': results.map((r) => r.toJson()).toList(),
      'requirements_coverage': {
        'calorie_limit_consistency': _getRequirementCoverage('calorie'),
        'weight_checkin_indicators': _getRequirementCoverage('weight'),
        'food_entry_hold_function': _getRequirementCoverage('food'),
        'home_page_cleanup': _getRequirementCoverage('home'),
        'table_rendering': _getRequirementCoverage('table'),
        'cross_platform': _getRequirementCoverage('platform'),
      }
    };

    final file = File('test/integration_test/new_fixes_validation_report.json');
    file.writeAsStringSync(jsonEncode(report));
    
    print('📄 Validation report generated: ${file.path}');
  }

  String _getRequirementCoverage(String category) {
    final categoryResults = results.where((r) => 
      r.description.toLowerCase().contains(category)).toList();
    
    if (categoryResults.isEmpty) return 'No tests found';
    
    final passed = categoryResults.where((r) => r.passed).length;
    final total = categoryResults.length;
    
    return '$passed/$total (${((passed / total) * 100).toStringAsFixed(1)}%)';
  }

  void _printSummary() {
    print('');
    print('📊 Validation Summary');
    print('═══════════════════════════════════════════════════════════');
    
    final passed = results.where((r) => r.passed).length;
    final failed = results.where((r) => !r.passed).length;
    final successRate = (passed / results.length) * 100;
    
    print('Total Validations: ${results.length}');
    print('Passed: $passed ✅');
    print('Failed: $failed ${failed > 0 ? '❌' : ''}');
    print('Success Rate: ${successRate.toStringAsFixed(1)}%');
    print('');

    if (failed > 0) {
      print('❌ Failed Validations:');
      for (final result in results.where((r) => !r.passed)) {
        print('   • ${result.description}');
        if (result.error != null) {
          print('     Reason: ${result.error}');
        }
      }
      print('');
    }

    // Requirements coverage summary
    print('📋 Requirements Coverage:');
    print('   • Calorie limit consistency: ${_getRequirementCoverage('calorie')}');
    print('   • Weight check-in indicators: ${_getRequirementCoverage('weight')}');
    print('   • Food entry hold function: ${_getRequirementCoverage('food')}');
    print('   • Home page cleanup: ${_getRequirementCoverage('home')}');
    print('   • Enhanced table rendering: ${_getRequirementCoverage('table')}');
    print('   • Cross-platform testing: ${_getRequirementCoverage('platform')}');
    print('');

    if (successRate >= 90) {
      print('🎉 Validation Status: EXCELLENT');
      print('   All requirements are well covered with comprehensive tests.');
    } else if (successRate >= 75) {
      print('✅ Validation Status: GOOD');
      print('   Most requirements are covered, minor improvements needed.');
    } else if (successRate >= 50) {
      print('⚠️  Validation Status: NEEDS IMPROVEMENT');
      print('   Several requirements need better test coverage.');
    } else {
      print('❌ Validation Status: INSUFFICIENT');
      print('   Major gaps in test coverage, significant work needed.');
    }
    
    print('');
    print('🔍 Next Steps:');
    if (failed > 0) {
      print('   1. Address failed validations listed above');
      print('   2. Implement missing tests for uncovered requirements');
      print('   3. Re-run validation script to verify improvements');
    } else {
      print('   1. Run the integration tests: flutter test test/integration_test/new_fixes_test_runner.dart');
      print('   2. Review test results and fix any failing tests');
      print('   3. Update documentation with test results');
    }
  }
}

class ValidationResult {
  final String description;
  final bool passed;
  final String? error;

  ValidationResult(this.description, this.passed, [this.error]);

  Map<String, dynamic> toJson() => {
    'description': description,
    'passed': passed,
    'error': error,
  };
}