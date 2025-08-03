part of 'chat_bloc.dart';

abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object?> get props => [];
}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatNoApiKey extends ChatState {}

class ChatLoaded extends ChatState {
  final List<ChatMessageEntity> messages;
  final String apiKey;
  final String selectedModel;
  final List<CustomModelEntity> customModels;
  final CustomModelEntity? activeModel;
  final bool isLoading;
  final bool showDebugMessages;

  const ChatLoaded({
    required this.messages,
    required this.apiKey,
    required this.selectedModel,
    required this.customModels,
    this.activeModel,
    this.isLoading = false,
    this.showDebugMessages = false,
  });

  @override
  List<Object?> get props => [
        messages,
        apiKey,
        selectedModel,
        customModels,
        activeModel,
        isLoading,
        showDebugMessages,
      ];

  ChatLoaded copyWith({
    List<ChatMessageEntity>? messages,
    String? apiKey,
    String? selectedModel,
    List<CustomModelEntity>? customModels,
    CustomModelEntity? activeModel,
    bool? isLoading,
    bool? showDebugMessages,
  }) {
    return ChatLoaded(
      messages: messages ?? this.messages,
      apiKey: apiKey ?? this.apiKey,
      selectedModel: selectedModel ?? this.selectedModel,
      customModels: customModels ?? this.customModels,
      activeModel: activeModel ?? this.activeModel,
      isLoading: isLoading ?? this.isLoading,
      showDebugMessages: showDebugMessages ?? this.showDebugMessages,
    );
  }
}

class ChatApiKeySaved extends ChatState {}

class ChatApiKeyRemoved extends ChatState {}

class ChatApiKeyViewed extends ChatState {
  final String apiKey;

  const ChatApiKeyViewed(this.apiKey);

  @override
  List<Object?> get props => [apiKey];
}

class ChatApiKeyChanged extends ChatState {}

class ChatCustomModelAdded extends ChatState {
  final CustomModelEntity model;

  const ChatCustomModelAdded(this.model);

  @override
  List<Object?> get props => [model];
}

class ChatCustomModelRemoved extends ChatState {
  final String identifier;

  const ChatCustomModelRemoved(this.identifier);

  @override
  List<Object?> get props => [identifier];
}

class ChatActiveModelSet extends ChatState {
  final String identifier;

  const ChatActiveModelSet(this.identifier);

  @override
  List<Object?> get props => [identifier];
}

class ChatCustomModelsLoaded extends ChatState {
  final List<CustomModelEntity> models;

  const ChatCustomModelsLoaded(this.models);

  @override
  List<Object?> get props => [models];
}

class ChatHistoryCleared extends ChatState {}

class ChatError extends ChatState {
  final String message;

  const ChatError(this.message);

  @override
  List<Object?> get props => [message];
} 