import 'package:equatable/equatable.dart';
import 'package:opennutritracker/features/chat/domain/entity/validation_result_entity.dart';

enum ChatMessageType {
  user,
  assistant,
  function_call, // New type for JSON messages
}

class ChatMessageEntity extends Equatable {
  final String id;
  final String content;
  final ChatMessageType type;
  final DateTime timestamp;
  final bool isVisible; // New field for visibility control
  final Map<String, dynamic>? functionData; // New field for JSON data
  final ValidationResult? validationResult; // New field for validation information
  final bool hasValidationFailure; // Quick check for validation issues

  const ChatMessageEntity({
    required this.id,
    required this.content,
    required this.type,
    required this.timestamp,
    this.isVisible = true,
    this.functionData,
    this.validationResult,
    this.hasValidationFailure = false,
  });

  @override
  List<Object?> get props => [
    id, 
    content, 
    type, 
    timestamp, 
    isVisible, 
    functionData, 
    validationResult, 
    hasValidationFailure
  ];

  ChatMessageEntity copyWith({
    String? id,
    String? content,
    ChatMessageType? type,
    DateTime? timestamp,
    bool? isVisible,
    Map<String, dynamic>? functionData,
    ValidationResult? validationResult,
    bool? hasValidationFailure,
  }) {
    return ChatMessageEntity(
      id: id ?? this.id,
      content: content ?? this.content,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isVisible: isVisible ?? this.isVisible,
      functionData: functionData ?? this.functionData,
      validationResult: validationResult ?? this.validationResult,
      hasValidationFailure: hasValidationFailure ?? this.hasValidationFailure,
    );
  }
} 