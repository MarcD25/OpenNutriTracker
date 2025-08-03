import 'package:flutter/foundation.dart';

class FunctionCallEntity {
  final String function;
  final Map<String, dynamic> parameters;
  final String? error;
  final bool success;

  const FunctionCallEntity({
    required this.function,
    required this.parameters,
    this.error,
    this.success = false,
  });

  factory FunctionCallEntity.fromJson(Map<String, dynamic> json) {
    return FunctionCallEntity(
      function: json['function'] as String,
      parameters: json['parameters'] as Map<String, dynamic>,
      error: json['error'] as String?,
      success: json['success'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'function': function,
      'parameters': parameters,
      'error': error,
      'success': success,
    };
  }

  @override
  String toString() {
    return 'FunctionCallEntity(function: $function, parameters: $parameters, error: $error, success: $success)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FunctionCallEntity &&
        other.function == function &&
        mapEquals(other.parameters, parameters) &&
        other.error == error &&
        other.success == success;
  }

  @override
  int get hashCode {
    return function.hashCode ^
        parameters.hashCode ^
        error.hashCode ^
        success.hashCode;
  }
}

class FunctionCallResult {
  final bool success;
  final String? error;
  final Map<String, dynamic>? data;

  const FunctionCallResult({
    required this.success,
    this.error,
    this.data,
  });

  factory FunctionCallResult.success([Map<String, dynamic>? data]) {
    return FunctionCallResult(success: true, data: data);
  }

  factory FunctionCallResult.error(String error) {
    return FunctionCallResult(success: false, error: error);
  }
} 