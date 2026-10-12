import '../../../../core/domain/exception/app_exception.dart';

class ValidationResult {
  final bool isValid;
  final List<ValidationIssue> issues;
  final String? correctedResponse;
  final ValidationSeverity severity;

  const ValidationResult({
    required this.isValid,
    required this.issues,
    this.correctedResponse,
    required this.severity,
  });

  ValidationResult copyWith({
    bool? isValid,
    List<ValidationIssue>? issues,
    String? correctedResponse,
    ValidationSeverity? severity,
  }) {
    return ValidationResult(
      isValid: isValid ?? this.isValid,
      issues: issues ?? this.issues,
      correctedResponse: correctedResponse ?? this.correctedResponse,
      severity: severity ?? this.severity,
    );
  }

  @override
  String toString() {
    return 'ValidationResult(isValid: $isValid, issues: $issues, severity: $severity)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ValidationResult &&
        other.isValid == isValid &&
        other.issues.toString() == issues.toString() &&
        other.correctedResponse == correctedResponse &&
        other.severity == severity;
  }

  @override
  int get hashCode {
    return isValid.hashCode ^
        issues.hashCode ^
        correctedResponse.hashCode ^
        severity.hashCode;
  }
}