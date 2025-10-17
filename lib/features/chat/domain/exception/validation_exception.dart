import '../../../../core/domain/exception/app_exception.dart';
import '../entity/validation_result_entity.dart';

class ValidationException extends AppException {
  final ValidationSeverity severity;
  final List<ValidationIssue> issues;
  final String? correctedValue;

  const ValidationException(
    String message,
    this.severity,
    this.issues, {
    this.correctedValue,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
  }) : super(
          message,
          code: code,
          originalError: originalError,
          stackTrace: stackTrace,
        );

  @override
  String toString() {
    return 'ValidationException: $message (Severity: $severity)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ValidationException &&
        other.message == message &&
        other.severity == severity &&
        other.issues.toString() == issues.toString() &&
        other.correctedValue == correctedValue;
  }

  @override
  int get hashCode {
    return message.hashCode ^ 
           severity.hashCode ^ 
           issues.hashCode ^ 
           (correctedValue?.hashCode ?? 0);
  }
}