import 'package:equatable/equatable.dart';

enum ChatMessageType {
  user,
  assistant,
}

class ChatMessageEntity extends Equatable {
  final String id;
  final String content;
  final ChatMessageType type;
  final DateTime timestamp;

  const ChatMessageEntity({
    required this.id,
    required this.content,
    required this.type,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [id, content, type, timestamp];

  ChatMessageEntity copyWith({
    String? id,
    String? content,
    ChatMessageType? type,
    DateTime? timestamp,
  }) {
    return ChatMessageEntity(
      id: id ?? this.id,
      content: content ?? this.content,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
    );
  }
} 