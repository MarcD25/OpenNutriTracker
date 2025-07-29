import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:opennutritracker/features/chat/domain/entity/chat_message_entity.dart';
import 'package:opennutritracker/features/chat/domain/entity/custom_model_entity.dart';

class ChatDataSource {
  static const String _apiKeyKey = 'openrouter_api_key';
  static const String _chatHistoryKey = 'chat_history';
  static const String _customModelsKey = 'custom_models';
  static const String _openRouterUrl = 'https://openrouter.ai/api/v1/chat/completions';
  
  final Logger _log = Logger('ChatDataSource');

  // Available models
  static const Map<String, String> availableModels = {
    'claude-3.5-sonnet': 'anthropic/claude-3.5-sonnet',
    'claude-3.5-haiku': 'anthropic/claude-3.5-haiku',
    'claude-3-opus': 'anthropic/claude-3-opus',
    'gpt-4': 'openai/gpt-4',
    'gpt-3.5-turbo': 'openai/gpt-3.5-turbo',
    'gemini-pro': 'google/gemini-pro',
    'llama-3.1': 'meta-llama/llama-3.1-8b-instruct',
  };

  static const String defaultModel = 'claude-3.5-sonnet';

  Future<String?> getApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    final apiKey = prefs.getString(_apiKeyKey);
    _log.info('Retrieved API key: ${apiKey != null ? '${apiKey.length} chars' : 'null'}');
    if (apiKey != null) {
      _log.info('API key starts with: ${apiKey.substring(0, apiKey.length > 10 ? 10 : apiKey.length)}...');
    }
    return apiKey;
  }

  Future<bool> hasApiKey() async {
    final apiKey = await getApiKey();
    return apiKey != null && apiKey.isNotEmpty;
  }

  Future<void> saveApiKey(String apiKey) async {
    final prefs = await SharedPreferences.getInstance();
    _log.info('Saving API key: ${apiKey.length} chars');
    _log.info('API key starts with: ${apiKey.substring(0, apiKey.length > 10 ? 10 : apiKey.length)}...');
    await prefs.setString(_apiKeyKey, apiKey);
  }

  Future<void> removeApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_apiKeyKey);
  }

  String maskApiKey(String apiKey) {
    if (apiKey.length <= 8) return '****';
    return '${apiKey.substring(0, 8)}****${apiKey.substring(apiKey.length - 4)}';
  }

  Future<List<CustomModelEntity>> getCustomModels() async {
    final prefs = await SharedPreferences.getInstance();
    final modelsJson = prefs.getString(_customModelsKey);
    if (modelsJson == null) return [];

    try {
      final List<dynamic> modelsList = json.decode(modelsJson);
      final models = modelsList.map((json) => CustomModelEntity.fromJson(json)).toList();
      _log.info('Loaded ${models.length} custom models: ${models.map((m) => '${m.identifier} (active: ${m.isActive})').join(', ')}');
      return models;
    } catch (e) {
      _log.warning('Error parsing custom models: $e');
      return [];
    }
  }

  Future<void> saveCustomModels(List<CustomModelEntity> models) async {
    final prefs = await SharedPreferences.getInstance();
    final modelsJson = json.encode(models.map((model) => model.toJson()).toList());
    await prefs.setString(_customModelsKey, modelsJson);
  }

  Future<void> addCustomModel(CustomModelEntity model) async {
    final models = await getCustomModels();
    
    // Check if model already exists
    if (models.any((m) => m.identifier == model.identifier)) {
      throw Exception('Model already exists');
    }

    // Set all other models as inactive
    final updatedModels = models.map((m) => m.copyWith(isActive: false)).toList();
    updatedModels.add(model.copyWith(isActive: true));
    
    await saveCustomModels(updatedModels);
  }

  Future<void> removeCustomModel(String identifier) async {
    final models = await getCustomModels();
    final updatedModels = models.where((m) => m.identifier != identifier).toList();
    
    // If we removed the active model, set the first remaining model as active
    if (models.any((m) => m.identifier == identifier && m.isActive) && updatedModels.isNotEmpty) {
      updatedModels[0] = updatedModels[0].copyWith(isActive: true);
    }
    
    await saveCustomModels(updatedModels);
  }

  Future<void> setActiveModel(String identifier) async {
    final models = await getCustomModels();
    final updatedModels = models.map((model) {
      return model.copyWith(isActive: model.identifier == identifier);
    }).toList();
    
    await saveCustomModels(updatedModels);
  }

  Future<CustomModelEntity?> getActiveModel() async {
    final models = await getCustomModels();
    return models.where((model) => model.isActive).firstOrNull;
  }

  Future<String> getSelectedModel() async {
    final activeModel = await getActiveModel();
    if (activeModel != null) {
      _log.info('Using active custom model: ${activeModel.identifier}');
      return activeModel.identifier;
    }
    _log.info('No active custom model, using default: anthropic/claude-3.5-sonnet');
    return availableModels[defaultModel]!;
  }

  Future<List<ChatMessageEntity>> getChatHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = prefs.getString(_chatHistoryKey);
    if (historyJson == null) return [];

    try {
      final List<dynamic> historyList = json.decode(historyJson);
      return historyList.map((json) => ChatMessageEntity(
        id: json['id'],
        content: json['content'],
        type: ChatMessageType.values.firstWhere(
          (e) => e.toString() == json['type'],
        ),
        timestamp: DateTime.parse(json['timestamp']),
      )).toList();
    } catch (e) {
      _log.warning('Error parsing chat history: $e');
      return [];
    }
  }

  Future<void> saveChatHistory(List<ChatMessageEntity> messages) async {
    final prefs = await SharedPreferences.getInstance();
    final historyJson = json.encode(messages.map((msg) => {
      'id': msg.id,
      'content': msg.content,
      'type': msg.type.toString(),
      'timestamp': msg.timestamp.toIso8601String(),
    }).toList());
    await prefs.setString(_chatHistoryKey, historyJson);
  }

  Future<void> clearChatHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_chatHistoryKey);
  }

  Future<void> clearAllChatData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_apiKeyKey);
    await prefs.remove(_chatHistoryKey);
    await prefs.remove(_customModelsKey);
    _log.info('Cleared all chat data');
  }

  Future<String> sendMessage(String message, String apiKey, String model, {String? userInfo}) async {
    try {
      _log.info('Sending message to OpenRouter with model: $model');
      _log.info('API key length: ${apiKey.length}');
      _log.info('API key starts with: ${apiKey.substring(0, apiKey.length > 10 ? 10 : apiKey.length)}...');
      _log.info('API key ends with: ...${apiKey.substring(apiKey.length - 4)}');
      _log.info('API key contains spaces: ${apiKey.contains(' ')}');
      _log.info('API key contains newlines: ${apiKey.contains('\n')}');
      _log.info('Request URL: $_openRouterUrl');
      _log.info('Request headers: ${{
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${apiKey.substring(0, 10)}...',
        'HTTP-Referer': 'https://opennutritracker.app',
        'X-Title': 'OpenNutriTracker',
        'User-Agent': 'OpenNutriTracker/1.0',
      }}');
      
      final requestBody = {
        'model': model,
        'messages': [
          {
            'role': 'system',
            'content': '''You are a helpful nutrition assistant for the OpenNutriTracker app. You can help users with:

1. **Food Tracking**: Help users add, edit, and delete food entries
2. **Calorie Calculation**: Calculate calories and macronutrients for foods
3. **History Viewing**: Help users understand their eating patterns
4. **Nutrition Advice**: Provide healthy eating tips and recommendations
5. **App Assistance**: Help users navigate and use the app features

**IMPORTANT: You can now directly add food entries to the user's diary!** When users provide food information, you can automatically add it to their diary. 

**CRITICAL: When adding food to the diary, you MUST use this EXACT format:**

```
Food Name: [name]
Calories: [calories per unit]
Protein: [grams per unit]
Carbs: [grams per unit]
Fat: [grams per unit]
Amount: [quantity consumed]
Unit: [g, ml, serving, etc.]
Meal Type: [breakfast/lunch/dinner/snack]
Date: [today/yesterday/tomorrow/specific date]
```

**Current Date Awareness:**
- Today's date: ${DateTime.now().toString().split(' ')[0]}
- Always consider the date when adding/reading/editing food entries
- When users mention "today", "yesterday", "tomorrow", or specific dates, use that date for diary operations

**Examples of when to add food entries:**
- User says "I had a banana for breakfast" → Add banana entry
- User says "I ate 200 calories of oatmeal" → Add oatmeal entry
- User says "I had chicken and rice for lunch" → Add both entries
- User says "I had a snack yesterday" → Add with yesterday's date

${userInfo != null ? '''
**User Profile Information:**
$userInfo

Use this information to provide personalized nutrition advice and recommendations. Consider the user's age, gender, height, weight, BMI, activity level, and weight goals when making suggestions.
''' : ''}

**Important**: Always respond using Markdown formatting for better readability. Use:
- **Bold** for emphasis
- *Italic* for secondary information
- `Code` for technical terms
- Lists with bullet points
- Tables when presenting data
- Code blocks for structured information

Always be helpful, accurate, and encouraging. When discussing nutrition, provide evidence-based advice. If you're unsure about something, say so rather than guessing.

Keep responses concise but informative. Use proper Markdown formatting to make information easy to scan and understand.

Note: Avoid using emojis in your responses as they may not display correctly in the app.'''
          },
          {
            'role': 'user',
            'content': message,
          }
        ],
        'max_tokens': 1000,
        'temperature': 0.7,
      };
      
      _log.info('Request body: ${json.encode(requestBody)}');
      
      final response = await http.post(
        Uri.parse(_openRouterUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
          'HTTP-Referer': 'https://opennutritracker.app',
          'X-Title': 'OpenNutriTracker',
          'User-Agent': 'OpenNutriTracker/1.0',
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        _log.severe('OpenRouter API error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to get response from AI assistant');
      }
    } catch (e) {
      _log.severe('Error sending message to OpenRouter: $e');
      throw Exception('Failed to connect to AI assistant');
    }
  }
} 