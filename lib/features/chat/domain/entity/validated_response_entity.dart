import 'package:opennutritracker/features/chat/domain/entity/validation_result_entity.dart';

class ValidatedResponse {
  final String response;
  final ValidationResult validationResult;

  const ValidatedResponse({
    required this.response,
    required this.validationResult,
  });
}