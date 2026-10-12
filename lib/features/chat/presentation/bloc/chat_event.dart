part of 'chat_bloc.dart';

abstract class ChatEvent extends Equatable {
  const ChatEvent();

  @override
  List<Object?> get props => [];
}

class LoadChatEvent extends ChatEvent {}

class SaveApiKeyEvent extends ChatEvent {
  final String apiKey;

  const SaveApiKeyEvent(this.apiKey);

  @override
  List<Object?> get props => [apiKey];
}

class RemoveApiKeyEvent extends ChatEvent {}

class ViewApiKeyEvent extends ChatEvent {}

class ChangeApiKeyEvent extends ChatEvent {
  final String newApiKey;

  const ChangeApiKeyEvent(this.newApiKey);

  @override
  List<Object?> get props => [newApiKey];
}

class AddCustomModelEvent extends ChatEvent {
  final String identifier;
  final String displayName;

  const AddCustomModelEvent(this.identifier, this.displayName);

  @override
  List<Object?> get props => [identifier, displayName];
}

class RemoveCustomModelEvent extends ChatEvent {
  final String identifier;

  const RemoveCustomModelEvent(this.identifier);

  @override
  List<Object?> get props => [identifier];
}

class SetActiveModelEvent extends ChatEvent {
  final String identifier;

  const SetActiveModelEvent(this.identifier);

  @override
  List<Object?> get props => [identifier];
}

class LoadCustomModelsEvent extends ChatEvent {}

class SendMessageEvent extends ChatEvent {
  final String message;

  const SendMessageEvent(this.message);

  @override
  List<Object?> get props => [message];
}

class ClearChatHistoryEvent extends ChatEvent {}

class DeleteMessageEvent extends ChatEvent {
  final String messageId;

  const DeleteMessageEvent(this.messageId);

  @override
  List<Object?> get props => [messageId];
}

class ToggleDebugModeEvent extends ChatEvent {} 