import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:opennutritracker/features/chat/domain/entity/chat_message_entity.dart';
import 'package:opennutritracker/features/chat/domain/entity/custom_model_entity.dart';
import 'package:opennutritracker/features/chat/domain/service/chat_processing_service.dart';
import 'package:opennutritracker/features/chat/domain/usecase/chat_usecase.dart';

part 'chat_event.dart';
part 'chat_state.dart';

class ChatBloc extends Bloc<ChatEvent, ChatState> {
  final Logger _log = Logger('ChatBloc');
  final ChatUsecase _chatUsecase;
  final ChatProcessingService _processingService = ChatProcessingService();
  bool _isProcessingMessage = false;
  
  // Debug mode persistence
  static const String _debugModeKey = 'chat_debug_mode';
  bool _showDebugMessages = false;

  ChatBloc(this._chatUsecase) : super(ChatInitial()) {
    on<LoadChatEvent>((event, emit) async {
      emit(ChatLoading());
      try {
        final apiKey = await _chatUsecase.getApiKey();
        final selectedModel = await _chatUsecase.getSelectedModel();
        final chatHistory = await _chatUsecase.getChatHistory();
        final customModels = await _chatUsecase.getCustomModels();
        final activeModel = await _chatUsecase.getActiveModel();
        
        // Load debug mode setting
        await _loadDebugMode();
        
        if (apiKey == null || apiKey.isEmpty) {
          emit(ChatNoApiKey());
        } else {
          emit(ChatLoaded(
            messages: chatHistory,
            apiKey: apiKey,
            selectedModel: selectedModel,
            customModels: customModels,
            activeModel: activeModel,
            showDebugMessages: _showDebugMessages,
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

    on<ToggleDebugModeEvent>((event, emit) async {
      try {
        _showDebugMessages = !_showDebugMessages;
        await _saveDebugMode();
        
        if (state is ChatLoaded) {
          final currentState = state as ChatLoaded;
          emit(ChatLoaded(
            messages: currentState.messages,
            apiKey: currentState.apiKey,
            selectedModel: currentState.selectedModel,
            customModels: currentState.customModels,
            activeModel: currentState.activeModel,
            showDebugMessages: _showDebugMessages,
          ));
        }
      } catch (e) {
        _log.severe('Error toggling debug mode: $e');
        emit(ChatError('Failed to toggle debug mode'));
      }
    });

    on<SendMessageEvent>((event, emit) async {
      if (state is ChatLoaded && !_isProcessingMessage) {
        _isProcessingMessage = true;
        final currentState = state as ChatLoaded;
        
        _log.info('Starting message processing in BLoC...');
        
        // Create a completer to track when processing is done
        final completer = Completer<void>();
        
        // Use the processing service for background processing
        // This will continue even if the BLoC is disposed
        _processingService.processMessage(
          message: event.message,
          apiKey: currentState.apiKey,
          selectedModel: currentState.selectedModel,
          chatHistory: currentState.messages,
          onUpdate: (messages) {
            // Update the UI with new messages
            // Only emit if the BLoC is still active and not completed
            if (!isClosed && !emit.isDone) {
              emit(ChatLoaded(
                messages: messages,
                apiKey: currentState.apiKey,
                selectedModel: currentState.selectedModel,
                customModels: currentState.customModels,
                activeModel: currentState.activeModel,
                showDebugMessages: _showDebugMessages,
                isLoading: messages.length > currentState.messages.length,
              ));
              _log.info('BLoC emitted updated state');
            } else {
              _log.info('BLoC is closed or emit is done, skipping emit');
            }
          },
          onError: (error) {
            _log.severe('Error sending message: $error');
            if (!isClosed && !emit.isDone) {
              emit(ChatError(error));
            }
            // Only complete if not already completed
            if (!completer.isCompleted) {
              completer.complete();
            }
          },
        ).then((_) {
          // Only complete if not already completed
          if (!completer.isCompleted) {
            completer.complete();
          }
        });
        
        // Wait for processing to complete before finishing the event handler
        await completer.future;
        _isProcessingMessage = false;
        _log.info('BLoC message processing completed');
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
            showDebugMessages: _showDebugMessages,
          ));
        } catch (e) {
          _log.severe('Error deleting message: $e');
          emit(ChatError('Failed to delete message'));
        }
      }
    });
  }

  // Debug mode persistence methods
  Future<void> _loadDebugMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _showDebugMessages = prefs.getBool(_debugModeKey) ?? false;
      _log.info('Loaded debug mode setting: $_showDebugMessages');
    } catch (e) {
      _log.warning('Error loading debug mode setting: $e');
      _showDebugMessages = false;
    }
  }

  Future<void> _saveDebugMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_debugModeKey, _showDebugMessages);
      _log.info('Saved debug mode setting: $_showDebugMessages');
    } catch (e) {
      _log.warning('Error saving debug mode setting: $e');
    }
  }
} 