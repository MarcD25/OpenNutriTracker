import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:opennutritracker/features/chat/domain/entity/chat_message_entity.dart';
import 'package:opennutritracker/features/chat/domain/entity/custom_model_entity.dart';
import 'package:opennutritracker/features/chat/domain/usecase/chat_usecase.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final Logger _log = Logger('ChatBloc');
  final ChatUsecase _chatUsecase;

  ChatBloc(this._chatUsecase) : super(ChatInitial()) {
    on<LoadChatEvent>((event, emit) async {
      emit(ChatLoading());
      try {
        final apiKey = await _chatUsecase.getApiKey();
        final selectedModel = await _chatUsecase.getSelectedModel();
        final chatHistory = await _chatUsecase.getChatHistory();
        final customModels = await _chatUsecase.getCustomModels();
        final activeModel = await _chatUsecase.getActiveModel();
        
        if (apiKey == null || apiKey.isEmpty) {
          emit(ChatNoApiKey());
        } else {
          emit(ChatLoaded(
            messages: chatHistory,
            apiKey: apiKey,
            selectedModel: selectedModel,
            customModels: customModels,
            activeModel: activeModel,
          ));
        }
      } catch (e) {
        _log.severe('Error loading chat: $e');
        emit(ChatError('Failed to load chat'));
      }
    });

    on<SaveApiKeyEvent>((event, emit) async {
      try {
        await _chatUsecase.saveApiKey(event.apiKey);
        emit(ChatApiKeySaved());
        add(LoadChatEvent());
      } catch (e) {
        _log.severe('Error saving API key: $e');
        emit(ChatError('Failed to save API key'));
      }
    });

    on<RemoveApiKeyEvent>((event, emit) async {
      try {
        await _chatUsecase.removeApiKey();
        emit(ChatApiKeyRemoved());
        add(LoadChatEvent());
      } catch (e) {
        _log.severe('Error removing API key: $e');
        emit(ChatError('Failed to remove API key'));
      }
    });

    on<ViewApiKeyEvent>((event, emit) async {
      try {
        final apiKey = await _chatUsecase.getApiKey();
        if (apiKey != null) {
          emit(ChatApiKeyViewed(apiKey));
        }
      } catch (e) {
        _log.severe('Error viewing API key: $e');
        emit(ChatError('Failed to view API key'));
      }
    });

    on<ChangeApiKeyEvent>((event, emit) async {
      try {
        await _chatUsecase.saveApiKey(event.newApiKey);
        emit(ChatApiKeyChanged());
        add(LoadChatEvent());
      } catch (e) {
        _log.severe('Error changing API key: $e');
        emit(ChatError('Failed to change API key'));
      }
    });

    on<AddCustomModelEvent>((event, emit) async {
      try {
        if (!_chatUsecase.isValidModelIdentifier(event.identifier)) {
          emit(ChatError('Invalid model identifier'));
          return;
        }
        
        await _chatUsecase.addCustomModel(event.identifier, event.displayName);
        final newModel = CustomModelEntity(
          identifier: event.identifier,
          displayName: event.displayName,
          addedAt: DateTime.now(),
          isActive: true,
        );
        emit(ChatCustomModelAdded(newModel));
        add(LoadChatEvent());
      } catch (e) {
        _log.severe('Error adding custom model: $e');
        emit(ChatError('Failed to add custom model'));
      }
    });

    on<RemoveCustomModelEvent>((event, emit) async {
      try {
        await _chatUsecase.removeCustomModel(event.identifier);
        emit(ChatCustomModelRemoved(event.identifier));
        add(LoadChatEvent());
      } catch (e) {
        _log.severe('Error removing custom model: $e');
        emit(ChatError('Failed to remove custom model'));
      }
    });

    on<SetActiveModelEvent>((event, emit) async {
      try {
        await _chatUsecase.setActiveModel(event.identifier);
        emit(ChatActiveModelSet(event.identifier));
        add(LoadChatEvent());
      } catch (e) {
        _log.severe('Error setting active model: $e');
        emit(ChatError('Failed to set active model'));
      }
    });

    on<LoadCustomModelsEvent>((event, emit) async {
      try {
        final models = await _chatUsecase.getCustomModels();
        emit(ChatCustomModelsLoaded(models));
      } catch (e) {
        _log.severe('Error loading custom models: $e');
        emit(ChatError('Failed to load custom models'));
      }
    });

    on<SendMessageEvent>((event, emit) async {
      if (state is ChatLoaded) {
        final currentState = state as ChatLoaded;
        final userMessage = _chatUsecase.createUserMessage(event.message);
        
        final updatedMessages = [...currentState.messages, userMessage];
        emit(ChatLoaded(
          messages: updatedMessages,
          apiKey: currentState.apiKey,
          selectedModel: currentState.selectedModel,
          customModels: currentState.customModels,
          activeModel: currentState.activeModel,
          isLoading: true,
        ));

        try {
          await _chatUsecase.saveChatHistory(updatedMessages);
          
          final assistantMessage = await _chatUsecase.sendMessage(
            event.message,
            currentState.apiKey,
            currentState.selectedModel,
          );

          final finalMessages = [...updatedMessages, assistantMessage];
          await _chatUsecase.saveChatHistory(finalMessages);

          emit(ChatLoaded(
            messages: finalMessages,
            apiKey: currentState.apiKey,
            selectedModel: currentState.selectedModel,
            customModels: currentState.customModels,
            activeModel: currentState.activeModel,
          ));
        } catch (e) {
          _log.severe('Error sending message: $e');
          emit(ChatLoaded(
            messages: updatedMessages,
            apiKey: currentState.apiKey,
            selectedModel: currentState.selectedModel,
            customModels: currentState.customModels,
            activeModel: currentState.activeModel,
          ));
          emit(ChatError('Failed to send message'));
        }
      }
    });

    on<ClearChatHistoryEvent>((event, emit) async {
      try {
        await _chatUsecase.clearChatHistory();
        emit(ChatHistoryCleared());
        add(LoadChatEvent());
      } catch (e) {
        _log.severe('Error clearing chat history: $e');
        emit(ChatError('Failed to clear chat history'));
      }
    });

    on<DeleteMessageEvent>((event, emit) async {
      if (state is ChatLoaded) {
        final currentState = state as ChatLoaded;
        final updatedMessages = currentState.messages
            .where((msg) => msg.id != event.messageId)
            .toList();
        
        try {
          await _chatUsecase.saveChatHistory(updatedMessages);
          emit(ChatLoaded(
            messages: updatedMessages,
            apiKey: currentState.apiKey,
            selectedModel: currentState.selectedModel,
            customModels: currentState.customModels,
            activeModel: currentState.activeModel,
          ));
        } catch (e) {
          _log.severe('Error deleting message: $e');
          emit(ChatError('Failed to delete message'));
        }
      }
    });
  }
} 