import 'package:equatable/equatable.dart';

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

  const ChatMessageEntity({
    required this.id,
    required this.content,
    required this.type,
    required this.timestamp,
    this.isVisible = true,
    this.functionData,
  });

  @override
  List<Object?> get props => [id, content, type, timestamp, isVisible, functionData];

  ChatMessageEntity copyWith({
    String? id,
    String? content,
    ChatMessageType? type,
    DateTime? timestamp,
    bool? isVisible,
    Map<String, dynamic>? functionData,
  }) {
    return ChatMessageEntity(
      id: id ?? this.id,
      content: content ?? this.content,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      isVisible: isVisible ?? this.isVisible,
      functionData: functionData ?? this.functionData,
    );
  }
} 