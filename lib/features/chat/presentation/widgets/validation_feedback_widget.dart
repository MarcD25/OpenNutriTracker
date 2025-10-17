import 'package:flutter/material.dart';
import 'package:opennutritracker/core/domain/exception/app_exception.dart';
import 'package:opennutritracker/features/chat/domain/entity/validation_result_entity.dart';

class ValidationFeedbackWidget extends StatefulWidget {
  final ValidationResult validationResult;
  final VoidCallback? onRetry;
  final bool showDebugInfo;

  const ValidationFeedbackWidget({
    super.key,
    required this.validationResult,
    this.onRetry,
    this.showDebugInfo = false,
  });

  @override
  State<ValidationFeedbackWidget> createState() => _ValidationFeedbackWidgetState();
}

class _ValidationFeedbackWidgetState extends State<ValidationFeedbackWidget> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    // Don't show anything if validation passed and no debug info requested
    if (widget.validationResult.isValid && !widget.showDebugInfo) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(top: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildValidationIndicator(),
          if (_isExpanded || widget.showDebugInfo) ...[
            const SizedBox(height: 8),
            _buildValidationDetails(),
          ],
        ],
      ),
    );
  }

  Widget _buildValidationIndicator() {
    final severity = widget.validationResult.severity;
    final isValid = widget.validationResult.isValid;
    
    Color indicatorColor;
    IconData indicatorIcon;
    String indicatorText;

    if (isValid) {
      indicatorColor = Colors.green;
      indicatorIcon = Icons.check_circle_outline;
      indicatorText = 'Response validated';
    } else {
      switch (severity) {
        case ValidationSeverity.critical:
          indicatorColor = Colors.red;
          indicatorIcon = Icons.error_outline;
          indicatorText = 'Critical validation issues';
          break;
        case ValidationSeverity.error:
          indicatorColor = Colors.orange;
          indicatorIcon = Icons.warning_outlined;
          indicatorText = 'Response quality issues';
          break;
        case ValidationSeverity.warning:
          indicatorColor = Colors.amber;
          indicatorIcon = Icons.info_outline;
          indicatorText = 'Minor quality concerns';
          break;
        case ValidationSeverity.info:
          indicatorColor = Colors.blue;
          indicatorIcon = Icons.info_outline;
          indicatorText = 'Response information';
          break;
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: indicatorColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: indicatorColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            indicatorIcon,
            color: indicatorColor,
            size: 16,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              indicatorText,
              style: TextStyle(
                color: indicatorColor,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (widget.validationResult.issues.isNotEmpty) ...[
            GestureDetector(
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              child: Icon(
                _isExpanded ? Icons.expand_less : Icons.expand_more,
                color: indicatorColor,
                size: 16,
              ),
            ),
          ],
          if (!isValid && widget.onRetry != null) ...[
            const SizedBox(width: 8),
            _buildRetryButton(indicatorColor),
          ],
        ],
      ),
    );
  }

  Widget _buildRetryButton(Color color) {
    return GestureDetector(
      onTap: widget.onRetry,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.refresh,
              color: Colors.white,
              size: 12,
            ),
            const SizedBox(width: 4),
            Text(
              'Retry',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildValidationDetails() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Validation Details',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          _buildValidationSummary(),
          if (widget.validationResult.issues.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildIssuesList(),
          ],
          if (widget.showDebugInfo) ...[
            const SizedBox(height: 8),
            _buildDebugInfo(),
          ],
        ],
      ),
    );
  }

  Widget _buildValidationSummary() {
    return Row(
      children: [
        Icon(
          widget.validationResult.isValid ? Icons.check_circle : Icons.cancel,
          color: widget.validationResult.isValid ? Colors.green : Colors.red,
          size: 14,
        ),
        const SizedBox(width: 6),
        Text(
          'Status: ${widget.validationResult.isValid ? 'Valid' : 'Invalid'}',
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(width: 16),
        Icon(
          _getSeverityIcon(widget.validationResult.severity),
          color: _getSeverityColor(widget.validationResult.severity),
          size: 14,
        ),
        const SizedBox(width: 6),
        Text(
          'Severity: ${widget.validationResult.severity.name.toUpperCase()}',
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildIssuesList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Issues Found:',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 11,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 4),
        ...widget.validationResult.issues.map((issue) => Padding(
          padding: const EdgeInsets.only(left: 8, top: 2),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '• ',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                ),
              ),
              Expanded(
                child: Text(
                  _getIssueDescription(issue),
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildDebugInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Debug Information:',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 11,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDebugRow('Has Corrected Response', 
                widget.validationResult.correctedResponse != null ? 'Yes' : 'No'),
              _buildDebugRow('Issue Count', 
                widget.validationResult.issues.length.toString()),
              _buildDebugRow('Validation Time', 
                DateTime.now().toIso8601String()),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDebugRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade600,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  IconData _getSeverityIcon(ValidationSeverity severity) {
    switch (severity) {
      case ValidationSeverity.critical:
        return Icons.dangerous;
      case ValidationSeverity.error:
        return Icons.error;
      case ValidationSeverity.warning:
        return Icons.warning;
      case ValidationSeverity.info:
        return Icons.info;
    }
  }

  Color _getSeverityColor(ValidationSeverity severity) {
    switch (severity) {
      case ValidationSeverity.critical:
        return Colors.red;
      case ValidationSeverity.error:
        return Colors.orange;
      case ValidationSeverity.warning:
        return Colors.amber;
      case ValidationSeverity.info:
        return Colors.blue;
    }
  }

  String _getIssueDescription(ValidationIssue issue) {
    switch (issue) {
      case ValidationIssue.responseTooLarge:
        return 'Response is unusually long and may contain excessive information';
      case ValidationIssue.missingNutritionInfo:
        return 'Required nutrition information is missing from the response';
      case ValidationIssue.unrealisticCalories:
        return 'Calorie values appear unrealistic or outside expected ranges';
      case ValidationIssue.incompleteResponse:
        return 'Response appears to be incomplete or cut off';
      case ValidationIssue.formatError:
        return 'Response format does not match expected structure';
      case ValidationIssue.invalidWeight:
        return 'Weight value is invalid or outside acceptable range';
      case ValidationIssue.invalidBMI:
        return 'BMI calculation resulted in invalid value';
      case ValidationIssue.unrealisticExerciseCalories:
        return 'Exercise calorie values appear unrealistic';
      case ValidationIssue.missingRequiredData:
        return 'Required data is missing from the input';
      case ValidationIssue.dataCorruption:
        return 'Data appears to be corrupted or malformed';
    }
  }
}