import 'dart:async';
import 'package:logging/logging.dart';
import 'package:opennutritracker/core/utils/locator.dart';
import 'package:opennutritracker/features/chat/domain/entity/chat_message_entity.dart';
import 'package:opennutritracker/features/chat/domain/usecase/chat_usecase.dart';

class ChatProcessingService {
  static final ChatProcessingService _instance = ChatProcessingService._internal();
  factory ChatProcessingService() => _instance;
  ChatProcessingService._internal() {
    _log.info('ChatProcessingService initialized');
  }

  final Logger _log = Logger('ChatProcessingService');
  ChatUsecase get _chatUsecase => locator<ChatUsecase>();
  
  bool _isProcessing = false;
  StreamController<bool>? _processingController;
  
  // Global processing state
  static bool _isGlobalProcessing = false;
  static bool get isGlobalProcessing => _isGlobalProcessing;
  
  // Instance processing state
  bool get isProcessing => _isProcessing;

  Stream<bool> get processingStream {
    _processingController ??= StreamController<bool>.broadcast();
    return _processingController!.stream;
  }

  Future<void> processMessage({
    required String message,
    required String apiKey,
    required String selectedModel,
    required List<ChatMessageEntity> chatHistory,
    required Function(List<ChatMessageEntity>) onUpdate,
    required Function(String) onError,
  }) async {
    if (_isProcessing) {
      _log.info('Already processing a message, ignoring new request');
      return;
    }

    _isProcessing = true;
    _isGlobalProcessing = true;
    _processingController?.add(true);

    try {
      _log.info('Starting message processing...');
      _log.info('Message: $message');
      _log.info('API Key length: ${apiKey.length}');
      _log.info('Selected model: $selectedModel');
      _log.info('Chat history length: ${chatHistory.length}');
      
      // Create user message
      final userMessage = _chatUsecase.createUserMessage(message);
      final updatedMessages = [...chatHistory, userMessage];
      
      _log.info('Created user message with ID: ${userMessage.id}');
      
      // Save initial state
      await _chatUsecase.saveChatHistory(updatedMessages);
      _log.info('Saved initial chat history');
      
      // Try to update UI, but don't let it fail the processing
      try {
        onUpdate(updatedMessages);
        _log.info('UI updated with initial messages');
      } catch (e) {
        _log.warning('Failed to update UI with initial messages: $e');
        // Continue processing even if UI update fails
      }

      // Process with AI - this is the critical part that must continue
      _log.info('Sending message to AI...');
      final assistantMessage = await _chatUsecase.sendMessage(
        message,
        apiKey,
        selectedModel,
        chatHistory: chatHistory,
      );

      _log.info('Received AI response with ID: ${assistantMessage.id}');
      _log.info('AI response content length: ${assistantMessage.content.length}');

      // Save final state
      final finalMessages = [...updatedMessages, assistantMessage];
      await _chatUsecase.saveChatHistory(finalMessages);
      _log.info('Saved final chat history');
      
      _log.info('Message processing completed successfully');
      
      // Try to update UI, but don't let it fail the processing
      try {
        onUpdate(finalMessages);
        _log.info('UI updated with final messages');
      } catch (e) {
        _log.warning('Failed to update UI with final messages: $e');
        // Processing completed successfully even if UI update fails
      }

    } catch (e) {
      _log.severe('Error processing message: $e');
      _log.severe('Error stack trace: ${StackTrace.current}');
      onError('Failed to send message: $e');
    } finally {
      _isProcessing = false;
      _isGlobalProcessing = false;
      _processingController?.add(false);
      _log.info('Message processing finished');
    }
  }

  void forceStopProcessing() {
    _log.info('Force stopping processing...');
    _isProcessing = false;
    _isGlobalProcessing = false;
    _processingController?.add(false);
  }

  void dispose() {
    _log.info('Disposing ChatProcessingService');
    _processingController?.close();
    _processingController = null;
  }
} 