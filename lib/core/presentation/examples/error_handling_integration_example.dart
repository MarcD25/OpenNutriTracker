import 'package:flutter/material.dart';
import '../mixins/error_handling_mixin.dart';
import '../../domain/exception/app_exception.dart';
import '../../domain/service/error_handling_service.dart';
import '../widgets/error_display_widget.dart';

/// Example showing how to integrate comprehensive error handling across features
class ErrorHandlingIntegrationExample extends StatefulWidget {
  const ErrorHandlingIntegrationExample({Key? key}) : super(key: key);

  @override
  State<ErrorHandlingIntegrationExample> createState() => _ErrorHandlingIntegrationExampleState();
}

class _ErrorHandlingIntegrationExampleState extends State<ErrorHandlingIntegrationExample>
    with ErrorHandlingMixin {
  bool _isLoading = false;
  AppException? _currentError;
  String _result = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Error Handling Examples'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Error banner example
            if (_currentError != null)
              ErrorBannerWidget(
                error: _currentError!,
                onRetry: _clearError,
                onDismiss: _clearError,
              ),
            
            const Text(
              'Error Handling Examples',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            // Validation error example
            _buildExampleSection(
              'Validation Error Example',
              'Simulate a validation error with recovery options',
              () => _simulateValidationError(),
            ),
            
            // Logistics error example
            _buildExampleSection(
              'Logistics Error Example',
              'Simulate a logistics tracking failure (graceful degradation)',
              () => _simulateLogisticsError(),
            ),
            
            // Weight check-in error example
            _buildExampleSection(
              'Weight Check-in Error Example',
              'Simulate a weight check-in failure with recovery options',
              () => _simulateWeightCheckinError(),
            ),
            
            // Calorie calculation error example
            _buildExampleSection(
              'Calorie Calculation Error Example',
              'Simulate a calorie calculation failure with fallback',
              () => _simulateCalorieCalculationError(),
            ),
            
            // Network error example
            _buildExampleSection(
              'Network Error Example',
              'Simulate a network failure with retry mechanism',
              () => _simulateNetworkError(),
            ),
            
            // Graceful degradation example
            _buildExampleSection(
              'Graceful Degradation Example',
              'Show how features degrade gracefully when they fail',
              () => _demonstrateGracefulDegradation(),
            ),
            
            const SizedBox(height: 24),
            
            // Results section
            if (_result.isNotEmpty) ...[
              const Text(
                'Result:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  border: Border.all(color: Colors.green[200]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(_result),
              ),
            ],
            
            // Loading indicator
            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: CircularProgressIndicator(),
                ),
              ),
            
            // Error display widget example
            if (_currentError != null) ...[
              const SizedBox(height: 16),
              ErrorDisplayWidget(
                error: _currentError!,
                onRetry: _clearError,
                onDismiss: _clearError,
                showRecoveryOptions: true,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildExampleSection(String title, String description, VoidCallback onTap) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ListTile(
        title: Text(title),
        subtitle: Text(description),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }

  void _simulateValidationError() {
    final error = ValidationException(
      'The calorie value 50000 seems unrealistic for a single meal',
      ValidationSeverity.warning,
      [ValidationIssue.unrealisticCalories],
      correctedValue: '500',
    );
    
    setState(() {
      _currentError = error;
    });
    
    handleValidationError(error, onRetry: _clearError);
  }

  void _simulateLogisticsError() {
    executeWithGracefulDegradation<void>(
      featureName: 'logistics_tracking',
      primaryOperation: () async {
        throw LogisticsException('Failed to write to logistics file');
      },
      fallbackOperation: () {
        setState(() {
          _result = 'Logistics tracking failed, but app continues normally';
        });
      },
    );
  }

  void _simulateWeightCheckinError() {
    final error = WeightCheckinException(
      'Unable to save weight entry. Please check your input.',
      code: 'WEIGHT_SAVE_FAILED',
    );
    
    setState(() {
      _currentError = error;
    });
    
    handleError(error, showRecoveryOptions: true);
  }

  void _simulateCalorieCalculationError() {
    executeWithErrorHandling<double>(
      operationName: 'Calculate BMI-adjusted calories',
      operation: () async {
        throw CalorieCalculationException('BMI calculation failed');
      },
      fallbackValue: 2000.0,
      showUserError: false,
    ).then((result) {
      setState(() {
        _result = 'Calorie calculation failed, using fallback: ${result?.toStringAsFixed(0)} calories';
      });
    });
  }

  void _simulateNetworkError() {
    setState(() {
      _isLoading = true;
    });
    
    executeWithErrorHandling<String>(
      operationName: 'Fetch nutrition data',
      operation: () async {
        await Future.delayed(const Duration(seconds: 2));
        throw Exception('Network connection failed');
      },
      showUserError: true,
      onError: () {
        setState(() {
          _isLoading = false;
        });
      },
    ).then((result) {
      setState(() {
        _isLoading = false;
        if (result != null) {
          _result = 'Network operation succeeded: $result';
        }
      });
    });
  }

  void _demonstrateGracefulDegradation() {
    // Simulate multiple feature failures
    final features = [
      'logistics_tracking',
      'llm_validation', 
      'bmi_calculation',
      'notifications'
    ];
    
    for (final feature in features) {
      executeWithGracefulDegradationSync<String>(
        featureName: feature,
        primaryOperation: () {
          throw Exception('$feature failed');
        },
        fallbackOperation: () {
          return '$feature is using fallback behavior';
        },
      );
    }
    
    final disabledFeatures = features.where((f) => isFeatureDisabled(f)).toList();
    
    setState(() {
      _result = 'Features with graceful degradation:\n${disabledFeatures.join('\n')}';
    });
    
    showInfoSnackBar(
      'Some features are running in degraded mode but the app continues to work',
    );
  }

  void _clearError() {
    setState(() {
      _currentError = null;
      _result = '';
    });
  }
}

/// Example of how to use error handling in a BLoC
class ExampleBloc {
  final ErrorHandlingService _errorHandlingService = ErrorHandlingService();

  Stream<String> processData(String input) async* {
    try {
      // Simulate processing
      await Future.delayed(const Duration(seconds: 1));
      
      if (input.isEmpty) {
        throw ValidationException(
          'Input cannot be empty',
          ValidationSeverity.error,
          [ValidationIssue.missingRequiredData],
        );
      }
      
      yield 'Processed: $input';
    } catch (error, stackTrace) {
      final appError = error is AppException
          ? error
          : AppException(
              'Failed to process data',
              originalError: error,
              stackTrace: stackTrace,
            );
      
      // Log error for analytics
      await ErrorLoggingService().logError(appError);
      
      // Re-throw for UI handling
      throw appError;
    }
  }
}

/// Example of how to use error handling in a repository
class ExampleRepository {
  Future<String> fetchData() async {
    return ErrorHandlingService.handleAsyncWithGracefulDegradation<String>(
      () async {
        // Simulate API call
        await Future.delayed(const Duration(seconds: 1));
        throw Exception('API is down');
      },
      'Cached data', // Fallback value
      operationName: 'Fetch remote data',
    );
  }
}