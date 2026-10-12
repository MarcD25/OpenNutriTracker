import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:opennutritracker/features/chat/data/data_source/chat_data_source.dart';
import 'package:opennutritracker/features/chat/domain/entity/chat_message_entity.dart';
import 'package:opennutritracker/features/chat/domain/entity/custom_model_entity.dart';
import 'package:opennutritracker/features/chat/domain/entity/function_call_entity.dart';
import 'package:opennutritracker/features/chat/domain/service/function_call_parser.dart';
import 'package:opennutritracker/features/chat/domain/service/function_execution_service.dart';
import 'package:opennutritracker/features/chat/domain/service/llm_response_validator.dart';
import 'package:opennutritracker/features/chat/domain/entity/validation_result_entity.dart';
import 'package:opennutritracker/features/chat/domain/entity/validated_response_entity.dart';
import 'package:opennutritracker/core/domain/exception/app_exception.dart';
import 'package:opennutritracker/core/utils/id_generator.dart';
import 'package:opennutritracker/core/domain/entity/user_gender_entity.dart';
import 'package:opennutritracker/core/domain/entity/intake_entity.dart';
import 'package:opennutritracker/core/domain/entity/intake_type_entity.dart';
import 'package:opennutritracker/core/domain/usecase/get_user_usecase.dart';
import 'package:opennutritracker/core/utils/calc/bmi_calc.dart';
import 'package:opennutritracker/features/chat/domain/usecase/ai_food_entry_usecase.dart';
import 'package:opennutritracker/features/chat/domain/usecase/chat_diary_data_usecase.dart';
import 'package:opennutritracker/core/domain/usecase/bulk_intake_operations_usecase.dart';
import 'package:opennutritracker/core/domain/usecase/logistics_tracking_usecase.dart';
import 'package:opennutritracker/core/domain/entity/logistics_event_entity.dart';
import 'package:logging/logging.dart';
import 'package:opennutritracker/core/utils/locator.dart';
import 'package:opennutritracker/core/domain/usecase/get_user_activity_usecase.dart';
import 'package:opennutritracker/core/domain/usecase/add_user_activity_usercase.dart';
import 'package:opennutritracker/core/domain/usecase/delete_user_activity_usecase.dart';
import 'package:opennutritracker/core/domain/usecase/get_physical_activity_usecase.dart';
import 'package:opennutritracker/core/domain/usecase/add_tracked_day_usecase.dart';
import 'package:opennutritracker/core/domain/usecase/get_kcal_goal_usecase.dart';
import 'package:opennutritracker/core/domain/usecase/get_macro_goal_usecase.dart';

class ChatUsecase {
  final ChatDataSource _chatDataSource;
  final GetUserUsecase _getUserUsecase;
  final AIFoodEntryUsecase _aiFoodEntryUsecase;
  final ChatDiaryDataUsecase _chatDiaryDataUsecase;
  final BulkIntakeOperationsUsecase _bulkIntakeOperationsUsecase;
  final FunctionExecutionService _functionExecutionService;
  final LLMResponseValidator _validator;
  final LogisticsTrackingUsecase _logisticsTrackingUsecase;
  final Logger _log = Logger('ChatUsecase');

  // Configuration constants for retry mechanism
  static const int maxRetryAttempts = 2;
  static const Duration retryDelay = Duration(seconds: 1);

  ChatUsecase(
    this._chatDataSource,
    this._getUserUsecase,
    this._aiFoodEntryUsecase,
    this._chatDiaryDataUsecase,
    this._bulkIntakeOperationsUsecase,
    this._validator,
    this._logisticsTrackingUsecase,
  ) : _functionExecutionService = FunctionExecutionService(
         _aiFoodEntryUsecase,
         _bulkIntakeOperationsUsecase,
         _chatDiaryDataUsecase,
         locator<GetUserActivityUsecase>(),
         locator<AddUserActivityUsecase>(),
         locator<DeleteUserActivityUsecase>(),
         locator<GetPhysicalActivityUsecase>(),
         locator<AddTrackedDayUsecase>(),
         locator<GetKcalGoalUsecase>(),
         locator<GetMacroGoalUsecase>(),
         locator<GetUserUsecase>(),
       );

  // API Key Management
  Future<String?> getApiKey() async {
    return await _chatDataSource.getApiKey();
  }

  Future<bool> hasApiKey() async {
    return await _chatDataSource.hasApiKey();
  }

  Future<void> saveApiKey(String apiKey) async {
    await _chatDataSource.saveApiKey(apiKey);
  }

  Future<void> removeApiKey() async {
    await _chatDataSource.removeApiKey();
  }

  String maskApiKey(String apiKey) {
    return _chatDataSource.maskApiKey(apiKey);
  }

  // Custom Model Management
  Future<List<CustomModelEntity>> getCustomModels() async {
    return await _chatDataSource.getCustomModels();
  }

  Future<void> addCustomModel(String identifier, String displayName) async {
    final model = CustomModelEntity(
      identifier: identifier.trim(),
      displayName: displayName.trim(),
      addedAt: DateTime.now(),
    );
    await _chatDataSource.addCustomModel(model);
  }

  Future<void> removeCustomModel(String identifier) async {
    await _chatDataSource.removeCustomModel(identifier);
  }

  Future<void> setActiveModel(String identifier) async {
    await _chatDataSource.setActiveModel(identifier);
  }

  Future<CustomModelEntity?> getActiveModel() async {
    return await _chatDataSource.getActiveModel();
  }

  Future<String> getSelectedModel() async {
    return await _chatDataSource.getSelectedModel();
  }

  // Model Validation
  bool isValidModelIdentifier(String identifier) {
    if (identifier.isEmpty) return false;
    
    // Basic validation: should contain at least one slash and not be empty
    final parts = identifier.split('/');
    if (parts.length < 2) return false;
    
    // Check if it looks like a valid model identifier
    return identifier.contains('/') && !identifier.startsWith('/') && !identifier.endsWith('/');
  }

  // Chat History Management
  Future<List<ChatMessageEntity>> getChatHistory() async {
    return await _chatDataSource.getChatHistory();
  }

  Future<void> saveChatHistory(List<ChatMessageEntity> messages) async {
    await _chatDataSource.saveChatHistory(messages);
  }

  Future<void> clearChatHistory() async {
    await _chatDataSource.clearChatHistory();
  }

  Future<void> clearAllChatData() async {
    await _chatDataSource.clearAllChatData();
  }

  // Message Handling with JSON-based Function Calling and Validation
  Future<List<ChatMessageEntity>> sendMessage(String message, String apiKey, String model, {List<ChatMessageEntity>? chatHistory}) async {
    final startTime = DateTime.now();
    final userInfo = await getUserInfoForChat();
    
    // First attempt: normal prompt with validation and retry
    final validatedResponse = await _sendMessageWithValidation(
      message,
      apiKey,
      model,
      userInfo: userInfo,
      chatHistory: chatHistory,
    );
    String response = validatedResponse.response;
    ValidationResult? validationResult = validatedResponse.validationResult;
    
    final responseTime = DateTime.now().difference(startTime);
    
    // Track chat interaction for analytics
    await _trackChatInteraction(message, response, responseTime);
    
    final List<ChatMessageEntity> messages = [];
    
    // Create user message
    final userMessage = ChatMessageEntity(
      id: IdGenerator.getUniqueID(),
      content: message,
      type: ChatMessageType.user,
      timestamp: DateTime.now(),
      isVisible: true,
    );
    messages.add(userMessage);
    
    // Parse function calls from AI response
    List<FunctionCallEntity> functionCalls = FunctionCallParser.parseFunctionCalls(response);
    _log.info('Found ${functionCalls.length} function calls in AI response');
    _log.info('Raw AI response: ${response.substring(0, response.length > 500 ? 500 : response.length)}...');

    // If no function calls were returned but the user intent looks like an action, retry in strict JSON-only mode
    if (functionCalls.isEmpty && _isActionIntent(message)) {
      _log.warning('No function call detected for action-intent message. Retrying with strict JSON-only mode.');
      final strictValidatedResponse = await _sendMessageWithValidation(
        message,
        apiKey,
        model,
        userInfo: userInfo,
        chatHistory: chatHistory,
        strictFunctionCall: true,
      );
      final strictCalls = FunctionCallParser.parseFunctionCalls(strictValidatedResponse.response);
      if (strictCalls.isNotEmpty) {
        response = strictValidatedResponse.response;
        validationResult = strictValidatedResponse.validationResult;
        functionCalls = strictCalls;
        _log.info('Strict mode succeeded: ${functionCalls.length} function call(s) parsed.');
      } else {
        _log.warning('Strict mode also returned no function calls. Proceeding with original assistant text.');
      }
    }
    
    // Execute function calls and get results
    List<FunctionCallResult> functionResults = [];
    if (functionCalls.isNotEmpty) {
      functionResults = await _functionExecutionService.executeFunctionCalls(functionCalls);
      
      // Create function call messages for debugging
      for (int i = 0; i < functionCalls.length; i++) {
        final functionCall = functionCalls[i];
        final result = functionResults[i];
        
        final functionMessage = ChatMessageEntity(
          id: IdGenerator.getUniqueID(),
          content: _formatFunctionCallForDisplay(functionCall, result),
          type: ChatMessageType.function_call,
          timestamp: DateTime.now(),
          isVisible: true, // Always visible for debugging
          functionData: {
            'function': functionCall.function,
            'parameters': functionCall.parameters,
            'success': result.success,
            'error': result.error,
            'data': result.data,
          },
        );
        messages.add(functionMessage);
      }
      
      // If we have function results, send them back to AI for a final response
      if (functionResults.any((result) => result.success)) {
        _log.info('Sending function results back to AI for final response');
        final finalValidatedResponse = await _sendFunctionResultsToAIWithValidation(
          message, 
          apiKey, 
          model, 
          functionCalls, 
          functionResults, 
          userInfo: userInfo, 
          chatHistory: chatHistory
        );
        
        // Extract visible content from final AI response
        final visibleContent = FunctionCallParser.extractVisibleContent(finalValidatedResponse.response);
        validationResult = finalValidatedResponse.validationResult;
        
        // Create assistant message with final content
        final assistantMessage = createAssistantMessage(
          visibleContent,
          validationResult: validationResult,
        );
        messages.add(assistantMessage);
      } else {
        // If no successful function calls, use original response
        final visibleContent = FunctionCallParser.extractVisibleContent(response);
        final assistantMessage = createAssistantMessage(
          visibleContent,
          validationResult: validationResult,
        );
        messages.add(assistantMessage);
      }
    } else {
      // No function calls, use original response
      final visibleContent = FunctionCallParser.extractVisibleContent(response);
      final assistantMessage = createAssistantMessage(
        visibleContent,
        validationResult: validationResult,
      );
      messages.add(assistantMessage);
    }
    
    // After each assistant reply, opportunistically update persistent summary/facts
    try {
      await _maybeUpdateSummaryAndFacts([...?chatHistory, ...messages]);
    } catch (_) {}
    return messages;
  }

  /// Sends message with validation and retry mechanism
  Future<ValidatedResponse> _sendMessageWithValidation(
    String message,
    String apiKey,
    String model, {
    String? userInfo,
    List<ChatMessageEntity>? chatHistory,
    bool strictFunctionCall = false,
  }) async {
    String? lastResponse;
    ValidationResult? lastValidationResult;
    
    for (int attempt = 0; attempt < maxRetryAttempts; attempt++) {
      try {
        // Send message to AI
        final response = await _chatDataSource.sendMessage(
          message,
          apiKey,
          model,
          userInfo: userInfo,
          chatHistory: chatHistory,
          strictFunctionCall: strictFunctionCall,
        );
        
        // Validate response
        final validationResult = _validator.validateResponse(response);
        lastValidationResult = validationResult;
        
        // Log validation result for analysis
        await _logValidationResult(validationResult, response, attempt + 1);
        
        // Handle validation result
        if (validationResult.isValid) {
          // Use corrected response if available, otherwise original
          final finalResponse = validationResult.correctedResponse ?? response;
          _log.info('Response validation passed on attempt ${attempt + 1}');
          return ValidatedResponse(
            response: finalResponse,
            validationResult: validationResult,
          );
        } else if (validationResult.severity == ValidationSeverity.critical) {
          // Critical validation failure - retry
          _log.warning('Critical validation failure on attempt ${attempt + 1}: ${validationResult.issues}');
          lastResponse = response;
          
          if (attempt < maxRetryAttempts - 1) {
            await Future.delayed(retryDelay);
            continue;
          }
        } else if (validationResult.severity == ValidationSeverity.error) {
          // Error level - retry but could fall back to corrected response
          _log.warning('Validation error on attempt ${attempt + 1}: ${validationResult.issues}');
          lastResponse = response;
          
          if (attempt < maxRetryAttempts - 1) {
            await Future.delayed(retryDelay);
            continue;
          } else {
            // Last attempt - use corrected response if available
            return ValidatedResponse(
              response: validationResult.correctedResponse ?? response,
              validationResult: validationResult,
            );
          }
        } else {
          // Warning or info level - use corrected response or original
          _log.info('Validation warning on attempt ${attempt + 1}: ${validationResult.issues}');
          return ValidatedResponse(
            response: validationResult.correctedResponse ?? response,
            validationResult: validationResult,
          );
        }
      } catch (e) {
        _log.severe('Error sending message on attempt ${attempt + 1}: $e');
        if (attempt == maxRetryAttempts - 1) {
          rethrow;
        }
        await Future.delayed(retryDelay);
      }
    }
    
    // All retries failed - handle gracefully
    if (lastResponse != null) {
      _log.warning('All validation retries failed, using last response with user-friendly error handling');
      final handledResponse = _handleValidationFailure(lastResponse, lastValidationResult);
      return ValidatedResponse(
        response: handledResponse,
        validationResult: lastValidationResult ?? ValidationResult(
          isValid: false,
          issues: [ValidationIssue.incompleteResponse],
          severity: ValidationSeverity.error,
        ),
      );
    }
    
    throw ValidationException(
      'Failed to get valid response after $maxRetryAttempts attempts',
      ValidationSeverity.critical,
      lastValidationResult?.issues ?? [],
    );
  }

  /// Logs validation results for analysis
  Future<void> _logValidationResult(
    ValidationResult validationResult,
    String response,
    int attemptNumber,
  ) async {
    try {
      final validationData = {
        'is_valid': validationResult.isValid,
        'severity': validationResult.severity.name,
        'issues': validationResult.issues.map((issue) => issue.name).toList(),
        'response_length': response.length,
        'attempt_number': attemptNumber,
        'has_corrected_response': validationResult.correctedResponse != null,
        'timestamp': DateTime.now().toIso8601String(),
      };

      await _logisticsTrackingUsecase.trackUserAction(
        LogisticsEventType.chatInteraction,
        validationData,
        metadata: {
          'validation_event': true,
          'component': 'llm_response_validator',
        },
      );
    } catch (e) {
      _log.warning('Failed to log validation result: $e');
      // Don't let logging failures affect the main flow
    }
  }

  /// Handles validation failure with user-friendly error messages
  String _handleValidationFailure(String originalResponse, ValidationResult? validationResult) {
    if (validationResult == null) {
      return originalResponse;
    }

    final buffer = StringBuffer();
    
    // Use corrected response if available
    if (validationResult.correctedResponse != null) {
      buffer.write(validationResult.correctedResponse!);
    } else {
      buffer.write(originalResponse);
    }

    // Add user-friendly validation warnings
    if (validationResult.issues.isNotEmpty) {
      buffer.write('\n\n---\n');
      buffer.write('⚠️ **Response Quality Notice**: ');
      
      final issueMessages = <String>[];
      for (final issue in validationResult.issues) {
        switch (issue) {
          case ValidationIssue.responseTooLarge:
            issueMessages.add('Response was truncated for readability');
            break;
          case ValidationIssue.missingNutritionInfo:
            issueMessages.add('Some nutrition information may be incomplete');
            break;
          case ValidationIssue.unrealisticCalories:
            issueMessages.add('Please verify calorie values seem reasonable');
            break;
          case ValidationIssue.incompleteResponse:
            issueMessages.add('Response may be incomplete');
            break;
          case ValidationIssue.formatError:
            issueMessages.add('Response formatting may have minor issues');
            break;
          case ValidationIssue.invalidWeight:
            issueMessages.add('Weight value seems invalid');
            break;
          case ValidationIssue.invalidBMI:
            issueMessages.add('BMI calculation seems invalid');
            break;
          case ValidationIssue.unrealisticExerciseCalories:
            issueMessages.add('Exercise calorie values seem unrealistic');
            break;
          case ValidationIssue.missingRequiredData:
            issueMessages.add('Some required data is missing');
            break;
          case ValidationIssue.dataCorruption:
            issueMessages.add('Data may be corrupted');
            break;
        }
      }
      
      buffer.write(issueMessages.join(', '));
      buffer.write('.');
    }

    return buffer.toString();
  }

  /// Tracks chat interaction for analytics
  Future<void> _trackChatInteraction(String message, String response, Duration responseTime) async {
    try {
      await _logisticsTrackingUsecase.trackChatInteraction(
        message,
        response,
        responseTime,
        additionalMetadata: {
          'has_validation': true,
          'response_length': response.length,
          'message_length': message.length,
        },
      );
    } catch (e) {
      _log.warning('Failed to track chat interaction: $e');
      // Don't let tracking failures affect the main flow
    }
  }

  // Heuristic: does the user ask to perform an action that requires a function?
  bool _isActionIntent(String text) {
    final t = text.toLowerCase();
    // Common verbs indicating diary actions
    final keywords = [
      'add ', 'log ', 'record ', 'track ', 'insert ', 'create ',
      'delete ', 'remove ', 'clear ', 'erase ',
      'update ', 'edit ', 'change ', 'modify ', 'move ', 'copy ',
      'get ', 'show ', 'list ', 'fetch ', 'read ', 'history ', 'diary ', 'progress ', 'entries ', 'activities ', 'exercise '
    ];
    return keywords.any((k) => t.contains(k));
  }

  /// Formats function call for display in debug mode
  String _formatFunctionCallForDisplay(FunctionCallEntity functionCall, FunctionCallResult result) {
    final buffer = StringBuffer();
    buffer.writeln('**Function Call:** ${functionCall.function}');
    buffer.writeln('**Status:** ${result.success ? '✅ Success' : '❌ Failed'}');
    
    if (result.error != null) {
      buffer.writeln('**Error:** ${result.error}');
    }
    
    if (result.data != null) {
      buffer.writeln('**Result:** ${result.data}');
    }
    
    buffer.writeln('**Parameters:**');
    functionCall.parameters.forEach((key, value) {
      buffer.writeln('- $key: $value');
    });
    
    return buffer.toString();
  }

  ChatMessageEntity createUserMessage(String content) {
    return ChatMessageEntity(
      id: IdGenerator.getUniqueID(),
      content: content,
      type: ChatMessageType.user,
      timestamp: DateTime.now(),
      isVisible: true,
    );
  }

  ChatMessageEntity createAssistantMessage(
    String content, {
    ValidationResult? validationResult,
    Map<String, dynamic>? functionData,
  }) {
    return ChatMessageEntity(
      id: IdGenerator.getUniqueID(),
      content: content,
      type: ChatMessageType.assistant,
      timestamp: DateTime.now(),
      isVisible: true,
      validationResult: validationResult,
      hasValidationFailure: validationResult != null && !validationResult.isValid,
      functionData: functionData,
    );
  }

  /// Sends function results back to AI for a final response with validation
  Future<ValidatedResponse> _sendFunctionResultsToAIWithValidation(
    String originalMessage,
    String apiKey,
    String model,
    List<FunctionCallEntity> functionCalls,
    List<FunctionCallResult> functionResults,
    {String? userInfo, List<ChatMessageEntity>? chatHistory}
  ) async {
    for (int attempt = 0; attempt < maxRetryAttempts; attempt++) {
      try {
        final response = await _sendFunctionResultsToAI(
          originalMessage,
          apiKey,
          model,
          functionCalls,
          functionResults,
          userInfo: userInfo,
          chatHistory: chatHistory,
        );

        // Validate the final response
        final validationResult = _validator.validateResponse(response);
        
        // Log validation result
        await _logValidationResult(validationResult, response, attempt + 1);

        if (validationResult.isValid || attempt == maxRetryAttempts - 1) {
          // Use corrected response if available, otherwise original
          return ValidatedResponse(
            response: validationResult.correctedResponse ?? response,
            validationResult: validationResult,
          );
        } else if (validationResult.severity == ValidationSeverity.critical ||
                   validationResult.severity == ValidationSeverity.error) {
          _log.warning('Function result response validation failed on attempt ${attempt + 1}: ${validationResult.issues}');
          if (attempt < maxRetryAttempts - 1) {
            await Future.delayed(retryDelay);
            continue;
          }
        }

        return ValidatedResponse(
          response: validationResult.correctedResponse ?? response,
          validationResult: validationResult,
        );
      } catch (e) {
        _log.severe('Error sending function results to AI on attempt ${attempt + 1}: $e');
        if (attempt == maxRetryAttempts - 1) {
          rethrow;
        }
        await Future.delayed(retryDelay);
      }
    }

    throw ValidationException(
      'Failed to get valid function result response after $maxRetryAttempts attempts',
      ValidationSeverity.critical,
      [],
    );
  }

  /// Sends function results back to AI for a final response (original method)
  Future<String> _sendFunctionResultsToAI(
    String originalMessage,
    String apiKey,
    String model,
    List<FunctionCallEntity> functionCalls,
    List<FunctionCallResult> functionResults,
    {String? userInfo, List<ChatMessageEntity>? chatHistory}
  ) async {
    try {
      // Build messages array with system message, chat history, original message, and function results
      final messages = [
        {
          'role': 'system',
          'content': '''You are a helpful nutrition assistant for the OpenNutriTracker app.

**IMPORTANT: Function calls have been executed and results are available below.**

Your task is to provide a helpful response to the user based on the function call results. 
Do NOT make any new function calls - just analyze the results and respond appropriately.

**Function Call Results:**
${_formatFunctionResultsForAI(functionCalls, functionResults)}

**Guidelines:**
1. If the function calls were successful, provide a helpful response based on the data
2. If there were errors, explain what went wrong and suggest alternatives
3. Be concise but informative
4. Use proper Markdown formatting
5. Avoid using emojis as they don't display correctly in the app
6. If the user asked to read their diary, summarize what you found
7. If the user asked to add/update/delete entries, confirm what was done

${userInfo != null ? '''
**User Profile Information:**
$userInfo

Use this information to provide personalized nutrition advice and recommendations.
''' : ''}'''
        }
      ];

      // Add chat history messages
      if (chatHistory != null) {
        for (final msg in chatHistory) {
          messages.add({
            'role': msg.type == ChatMessageType.user ? 'user' : 'assistant',
            'content': msg.content,
          });
        }
      }

      // Add the original user message
      messages.add({
        'role': 'user',
        'content': originalMessage,
      });

      final requestBody = {
        'model': model,
        'messages': messages,
        'max_tokens': 10000,
        'temperature': 0.7,
      };
      
      _log.info('Sending function results to AI for final response');
      
             final response = await http.post(
         Uri.parse('https://openrouter.ai/api/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
          'HTTP-Referer': 'https://opennutritracker.app',
          'X-Title': 'OpenNutriTracker',
          'User-Agent': 'OpenNutriTracker/1.0',
        },
        body: json.encode(requestBody),
      ).timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          throw Exception('Request timed out. Please try again.');
        },
      );

      if (response.statusCode == 200) {
        final responseBody = utf8.decode(response.bodyBytes);
        final data = json.decode(responseBody);
        final content = data['choices'][0]['message']['content'];
        _log.info('Received final AI response with ${content.length} characters');
        // Try to update summary/facts based on final content
        try {
          await _maybeUpdateSummaryAndFacts(chatHistory ?? [], finalAssistantContent: content);
        } catch (_) {}
        return content;
      } else {
        _log.severe('OpenRouter API error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to get final response from AI assistant');
      }
    } catch (e) {
      _log.severe('Error sending function results to AI: $e');
      throw Exception('Failed to process function results');
    }
  }

  // Summarization and persistent facts
  Future<void> _maybeUpdateSummaryAndFacts(List<ChatMessageEntity> fullThread, {String? finalAssistantContent}) async {
    // Only summarize when thread grows big or final content supplied
    if ((fullThread.length < 30) && finalAssistantContent == null) return;

    final model = await getSelectedModel();
    final apiKey = (await getApiKey()) ?? '';
    if (apiKey.isEmpty) return;

    // Build compact text transcript
    final transcript = StringBuffer();
    for (final m in fullThread.take(200)) {
      final role = m.type == ChatMessageType.user ? 'User' : (m.type == ChatMessageType.assistant ? 'Assistant' : 'Function');
      transcript.writeln('$role: ${m.content}');
    }
    if (finalAssistantContent != null) {
      transcript.writeln('Assistant: $finalAssistantContent');
    }

    final prompt = '''Summarize the user's recurring nutrition habits/preferences concisely (max 1200 chars). Then extract 3-10 durable facts as short bullet points suitable as stable memory. Output JSON with keys "summary" and "facts" (facts is an array of strings).''';

    final requestBody = {
      'model': model,
      'messages': [
        {'role': 'system', 'content': 'You are a helpful assistant that produces compact JSON summaries.'},
        {'role': 'user', 'content': '$prompt\n\nTranscript:\n${transcript.toString()}'}
      ],
      'max_tokens': 1200,
      'temperature': 0.2,
    };

    final resp = await http.post(
      Uri.parse('https://openrouter.ai/api/v1/chat/completions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
        'HTTP-Referer': 'https://opennutritracker.app',
        'X-Title': 'OpenNutriTracker',
        'User-Agent': 'OpenNutriTracker/1.0',
      },
      body: json.encode(requestBody),
    );
    if (resp.statusCode != 200) return;
    final body = json.decode(utf8.decode(resp.bodyBytes));
    final content = body['choices'][0]['message']['content'];
    try {
      final parsed = json.decode(content);
      final summary = (parsed['summary'] ?? '').toString();
      final factsList = (parsed['facts'] as List?)?.map((e) => e.toString()).toList() ?? [];
      final facts = factsList.map((e) => '- $e').join('\n');
      if (summary.isNotEmpty) {
        await _chatDataSource.setPersistentSummary(summary);
      }
      if (facts.isNotEmpty) {
        await _chatDataSource.setPersistentFacts(facts);
      }
    } catch (_) {
      // ignore parse errors
    }
  }

  /// Formats function results for AI consumption
  String _formatFunctionResultsForAI(List<FunctionCallEntity> functionCalls, List<FunctionCallResult> functionResults) {
    final buffer = StringBuffer();
    
    for (int i = 0; i < functionCalls.length; i++) {
      final functionCall = functionCalls[i];
      final result = functionResults[i];
      
      buffer.writeln('**Function:** ${functionCall.function}');
      buffer.writeln('**Status:** ${result.success ? 'SUCCESS' : 'FAILED'}');
      
      if (result.error != null) {
        buffer.writeln('**Error:** ${result.error}');
      }
      
      if (result.data != null) {
        buffer.writeln('**Result:**');
        buffer.writeln('```json');
        buffer.writeln(json.encode(result.data));
        buffer.writeln('```');
      }
      
      buffer.writeln('**Parameters:**');
      functionCall.parameters.forEach((key, value) {
        buffer.writeln('- $key: $value');
      });
      
      buffer.writeln('---');
    }
    
    return buffer.toString();
  }

  // User Information for Chat Context
  Future<String> getUserInfoForChat() async {
    try {
      final user = await _getUserUsecase.getUserData();
      final bmi = BMICalc.getBMI(user);
      final bmiStatus = BMICalc.getNutritionalStatus(bmi);
      
      // Get recent diary data
      final recentProgress = await _chatDiaryDataUsecase.getRecentProgressSummary(days: 7);
      final todayDiaryData = await _chatDiaryDataUsecase.getDiaryDataForAI(
        specificDate: DateTime.now(),
        includeFoodEntries: true,
        includeProgress: true,
      );
      
      return '''User Profile:
- Age: ${user.age} years old
- Gender: ${user.gender == UserGenderEntity.male ? 'Male' : 'Female'}
- Height: ${user.heightCM.toStringAsFixed(1)} cm
- Weight: ${user.weightKG.toStringAsFixed(1)} kg
- BMI: ${bmi.toStringAsFixed(1)} (${bmiStatus.toString().split('.').last})
- Activity Level: ${user.pal.toString().split('.').last}
- Weight Goal: ${user.goal.toString().split('.').last}

**Recent Progress (Last 7 Days):**
$recentProgress

**Today's Diary Data:**
$todayDiaryData''';
    } catch (e) {
      _log.severe('Error getting user info for chat: $e');
      return 'User profile information not available.';
    }
  }

  // AI Food Entry Methods (kept for backward compatibility)
  Future<void> addFoodEntry({
    required String foodName,
    required double calories,
    required double protein,
    required double carbs,
    required double fat,
    required double amount,
    required String unit,
    required String mealType,
    DateTime? date,
  }) async {
    await _aiFoodEntryUsecase.addFoodEntry(
      foodName: foodName,
      calories: calories,
      protein: protein,
      carbs: carbs,
      fat: fat,
      amount: amount,
      unit: unit,
      mealType: mealType,
      date: date,
    );
  }

  Future<void> addMultipleFoodEntries({
    required List<Map<String, dynamic>> foodEntries,
    DateTime? date,
  }) async {
    await _aiFoodEntryUsecase.addMultipleFoodEntries(
      foodEntries: foodEntries,
      date: date,
    );
  }

  /// Gets the current date for AI operations
  DateTime getCurrentDate() {
    return DateTime.now();
  }

  /// Parses a date string and returns a DateTime object
  DateTime? parseDate(String dateString) {
    try {
      // Try to parse the date string directly
      try {
        return DateTime.parse(dateString);
      } catch (e) {
        // If direct parsing fails, continue to phrase parsing
      }
      
      // If no format works, try to extract date from common phrases
      final lowerDate = dateString.toLowerCase();
      if (lowerDate.contains('today') || lowerDate.contains('now')) {
        return DateTime.now();
      } else if (lowerDate.contains('yesterday')) {
        return DateTime.now().subtract(const Duration(days: 1));
      } else if (lowerDate.contains('tomorrow')) {
        return DateTime.now().add(const Duration(days: 1));
      }
      
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Parses a date string and returns a list of DateTime objects for bulk operations
  List<DateTime> parseDateRange(String dateString) {
    try {
      final lowerDate = dateString.toLowerCase();
      
      // Handle single dates
      if (lowerDate == 'today') {
        return [DateTime.now()];
      } else if (lowerDate == 'yesterday') {
        return [DateTime.now().subtract(const Duration(days: 1))];
      } else if (lowerDate == 'tomorrow') {
        return [DateTime.now().add(const Duration(days: 1))];
      }
      
      // Handle date ranges like "[each June date: 1/6/2025 through 30/6/2025]"
      final rangeMatch = RegExp(r'\[each\s+(\w+)\s+date[:\s]+(\d{1,2}/\d{1,2}/\d{4})\s+through\s+(\d{1,2}/\d{1,2}/\d{4})\]', caseSensitive: false);
      final rangeMatchResult = rangeMatch.firstMatch(dateString);
      if (rangeMatchResult != null) {
        final startDateStr = rangeMatchResult.group(2)!;
        final endDateStr = rangeMatchResult.group(3)!;
        
        try {
          final startDate = _parseDateString(startDateStr);
          final endDate = _parseDateString(endDateStr);
          
          if (startDate != null && endDate != null) {
            return _generateDateRange(startDate, endDate);
          }
        } catch (e) {
          _log.severe('Error parsing date range: $e');
        }
      }
      
      // Handle month ranges like "[each June date]"
      final monthMatch = RegExp(r'\[each\s+(\w+)\s+date\]', caseSensitive: false);
      final monthMatchResult = monthMatch.firstMatch(dateString);
      if (monthMatchResult != null) {
        final monthName = monthMatchResult.group(1)!;
        return _generateMonthRange(monthName);
      }
      
      // Handle simple date format
      final singleDate = parseDate(dateString);
      if (singleDate != null) {
        return [singleDate];
      }
      
      // Default to today if parsing fails
      return [DateTime.now()];
    } catch (e) {
      _log.severe('Error parsing date range: $e');
      return [DateTime.now()];
    }
  }

  /// Parses a date string in DD/MM/YYYY format
  DateTime? _parseDateString(String dateStr) {
    try {
      final parts = dateStr.split('/');
      if (parts.length == 3) {
        final day = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final year = int.parse(parts[2]);
        return DateTime(year, month, day);
      }
    } catch (e) {
      _log.severe('Error parsing date string: $dateStr');
    }
    return null;
  }

  /// Generates a list of dates from start to end (inclusive)
  List<DateTime> _generateDateRange(DateTime start, DateTime end) {
    final dates = <DateTime>[];
    var current = start;
    
    while (current.isBefore(end) || current.isAtSameMomentAs(end)) {
      dates.add(current);
      current = current.add(const Duration(days: 1));
    }
    
    _log.info('Generated ${dates.length} dates from ${start.toString().split(' ')[0]} to ${end.toString().split(' ')[0]}');
    return dates;
  }

  /// Generates a list of dates for a specific month
  List<DateTime> _generateMonthRange(String monthName) {
    final now = DateTime.now();
    final currentYear = now.year;
    
    // Map month names to month numbers
    final monthMap = {
      'january': 1, 'february': 2, 'march': 3, 'april': 4,
      'may': 5, 'june': 6, 'july': 7, 'august': 8,
      'september': 9, 'october': 10, 'november': 11, 'december': 12
    };
    
    final monthNumber = monthMap[monthName.toLowerCase()];
    if (monthNumber == null) {
      _log.severe('Unknown month: $monthName');
      return [DateTime.now()];
    }
    
    final startDate = DateTime(currentYear, monthNumber, 1);
    final endDate = DateTime(currentYear, monthNumber + 1, 0); // Last day of the month
    
    return _generateDateRange(startDate, endDate);
  }

  // Bulk Operations Methods

  /// Deletes all intake entries for a specific date
  Future<void> deleteAllIntakesForDate(DateTime date) async {
    await _bulkIntakeOperationsUsecase.deleteAllIntakesForDate(date);
  }

  /// Deletes all intake entries for a specific meal type on a specific date
  Future<void> deleteIntakesForDateAndType(String mealType, DateTime date) async {
    final intakeType = _getIntakeTypeFromString(mealType);
    await _bulkIntakeOperationsUsecase.deleteIntakesForDateAndType(intakeType, date);
  }

  /// Deletes all intake entries for a date range
  Future<void> deleteAllIntakesForDateRange(DateTime startDate, DateTime endDate) async {
    await _bulkIntakeOperationsUsecase.deleteAllIntakesForDateRange(startDate, endDate);
  }

  /// Deletes all intake entries for a specific meal type across all dates
  Future<void> deleteAllIntakesByType(String mealType) async {
    final intakeType = _getIntakeTypeFromString(mealType);
    await _bulkIntakeOperationsUsecase.deleteAllIntakesByType(intakeType);
  }

  /// Deletes all intake entries for a specific meal type in a date range
  Future<void> deleteIntakesByTypeAndDateRange(String mealType, DateTime startDate, DateTime endDate) async {
    final intakeType = _getIntakeTypeFromString(mealType);
    await _bulkIntakeOperationsUsecase.deleteIntakesByTypeAndDateRange(intakeType, startDate, endDate);
  }

  /// Updates multiple intake entries with the same fields
  Future<void> updateMultipleIntakes(List<String> intakeIds, Map<String, dynamic> fields) async {
    await _bulkIntakeOperationsUsecase.updateMultipleIntakes(intakeIds, fields);
  }

  /// Gets all intake entries for a date range
  Future<List<IntakeEntity>> getAllIntakesForDateRange(DateTime startDate, DateTime endDate) async {
    return await _bulkIntakeOperationsUsecase.getAllIntakesForDateRange(startDate, endDate);
  }

  /// Gets all intake entries for a specific meal type
  Future<List<IntakeEntity>> getAllIntakesByType(String mealType) async {
    final intakeType = _getIntakeTypeFromString(mealType);
    return await _bulkIntakeOperationsUsecase.getAllIntakesByType(intakeType);
  }

  /// Gets all intake entries for a specific meal type in a date range
  Future<List<IntakeEntity>> getAllIntakesByTypeAndDateRange(String mealType, DateTime startDate, DateTime endDate) async {
    final intakeType = _getIntakeTypeFromString(mealType);
    return await _bulkIntakeOperationsUsecase.getAllIntakesByTypeAndDateRange(intakeType, startDate, endDate);
  }

  /// Gets a summary of available bulk operations
  String getBulkOperationsSummary() {
    return _bulkIntakeOperationsUsecase.getBulkOperationsSummary();
  }

  /// Converts meal type string to IntakeTypeEntity
  IntakeTypeEntity _getIntakeTypeFromString(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return IntakeTypeEntity.breakfast;
      case 'lunch':
        return IntakeTypeEntity.lunch;
      case 'dinner':
        return IntakeTypeEntity.dinner;
      case 'snack':
        return IntakeTypeEntity.snack;
      default:
        return IntakeTypeEntity.snack; // Default to snack
    }
  }
} 