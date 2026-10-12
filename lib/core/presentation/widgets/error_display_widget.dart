import 'package:flutter/material.dart';
import '../../domain/exception/app_exception.dart';
import '../../domain/service/recovery_options_service.dart';

/// Widget for displaying error information with recovery options
class ErrorDisplayWidget extends StatelessWidget {
  final AppException error;
  final VoidCallback? onRetry;
  final VoidCallback? onDismiss;
  final bool showRecoveryOptions;
  final bool showDetails;

  const ErrorDisplayWidget({
    Key? key,
    required this.error,
    this.onRetry,
    this.onDismiss,
    this.showRecoveryOptions = true,
    this.showDetails = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            const SizedBox(height: 12),
            _buildMessage(),
            if (showDetails && error.code != null) ...[
              const SizedBox(height: 8),
              _buildErrorCode(),
            ],
            if (error is ValidationException) ...[
              const SizedBox(height: 12),
              _buildValidationIssues(error as ValidationException),
            ],
            const SizedBox(height: 16),
            _buildActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    IconData icon;
    Color color;
    String title;

    if (error is ValidationException) {
      final validationError = error as ValidationException;
      switch (validationError.severity) {
        case ValidationSeverity.critical:
          icon = Icons.error;
          color = Colors.red;
          title = 'Critical Error';
          break;
        case ValidationSeverity.error:
          icon = Icons.warning;
          color = Colors.orange;
          title = 'Error';
          break;
        case ValidationSeverity.warning:
          icon = Icons.info;
          color = Colors.amber;
          title = 'Warning';
          break;
        case ValidationSeverity.info:
          icon = Icons.info_outline;
          color = Colors.blue;
          title = 'Information';
          break;
      }
    } else {
      icon = Icons.error_outline;
      color = Colors.red;
      title = 'Error';
    }

    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildMessage() {
    return Text(
      error.message,
      style: const TextStyle(fontSize: 16),
    );
  }

  Widget _buildErrorCode() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        'Error Code: ${error.code}',
        style: const TextStyle(
          fontSize: 12,
          fontFamily: 'monospace',
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildValidationIssues(ValidationException validationError) {
    if (validationError.issues.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Issues:',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        ...validationError.issues.map((issue) => Padding(
          padding: const EdgeInsets.only(left: 16, bottom: 2),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
              Expanded(child: Text(_getIssueDescription(issue))),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildActions(BuildContext context) {
    final recoveryService = RecoveryOptionsService();
    
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        if (onRetry != null)
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
          ),
        if (showRecoveryOptions)
          OutlinedButton.icon(
            onPressed: () {
              recoveryService.showRecoveryDialog(
                context,
                error,
                onDismiss: onDismiss,
              );
            },
            icon: const Icon(Icons.build),
            label: const Text('Recovery Options'),
          ),
        if (onDismiss != null)
          TextButton(
            onPressed: onDismiss,
            child: const Text('Dismiss'),
          ),
      ],
    );
  }

  String _getIssueDescription(ValidationIssue issue) {
    switch (issue) {
      case ValidationIssue.responseTooLarge:
        return 'Response exceeds maximum length';
      case ValidationIssue.missingNutritionInfo:
        return 'Required nutrition information is missing';
      case ValidationIssue.unrealisticCalories:
        return 'Calorie values are outside realistic range';
      case ValidationIssue.incompleteResponse:
        return 'Response appears to be incomplete';
      case ValidationIssue.formatError:
        return 'Response format is invalid';
      case ValidationIssue.invalidWeight:
        return 'Weight value is invalid';
      case ValidationIssue.invalidBMI:
        return 'BMI calculation resulted in invalid value';
      case ValidationIssue.unrealisticExerciseCalories:
        return 'Exercise calories are unrealistically high';
      case ValidationIssue.missingRequiredData:
        return 'Required data is missing';
      case ValidationIssue.dataCorruption:
        return 'Data appears to be corrupted';
    }
  }
}

/// Compact error display widget for inline use
class CompactErrorWidget extends StatelessWidget {
  final AppException error;
  final VoidCallback? onRetry;
  final VoidCallback? onDismiss;

  const CompactErrorWidget({
    Key? key,
    required this.error,
    this.onRetry,
    this.onDismiss,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.red[50],
        border: Border.all(color: Colors.red[200]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red[700], size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              error.message,
              style: TextStyle(
                color: Colors.red[700],
                fontSize: 14,
              ),
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(width: 8),
            IconButton(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              iconSize: 20,
              color: Colors.red[700],
              tooltip: 'Retry',
            ),
          ],
          if (onDismiss != null) ...[
            const SizedBox(width: 4),
            IconButton(
              onPressed: onDismiss,
              icon: const Icon(Icons.close),
              iconSize: 20,
              color: Colors.red[700],
              tooltip: 'Dismiss',
            ),
          ],
        ],
      ),
    );
  }
}

/// Error banner widget for top-level error display
class ErrorBannerWidget extends StatelessWidget {
  final AppException error;
  final VoidCallback? onRetry;
  final VoidCallback? onDismiss;
  final bool isVisible;

  const ErrorBannerWidget({
    Key? key,
    required this.error,
    this.onRetry,
    this.onDismiss,
    this.isVisible = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox.shrink();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: isVisible ? null : 0,
      child: Container(
        width: double.infinity,
        color: Colors.red[100],
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red[700]),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Error',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red[700],
                    ),
                  ),
                  Text(
                    error.message,
                    style: TextStyle(color: Colors.red[700]),
                  ),
                ],
              ),
            ),
            if (onRetry != null) ...[
              const SizedBox(width: 8),
              TextButton(
                onPressed: onRetry,
                child: Text(
                  'Retry',
                  style: TextStyle(color: Colors.red[700]),
                ),
              ),
            ],
            IconButton(
              onPressed: onDismiss,
              icon: const Icon(Icons.close),
              color: Colors.red[700],
            ),
          ],
        ),
      ),
    );
  }
}