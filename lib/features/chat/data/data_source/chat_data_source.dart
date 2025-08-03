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
    _log.info('Saved chat history with ${messages.length} messages');
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

  Future<String> sendMessage(String message, String apiKey, String model, {String? userInfo, List<ChatMessageEntity>? chatHistory}) async {
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
      
      // Build messages array with system message, chat history, and current message
      final messages = [
                  {
            'role': 'system',
            'content': '''You are a helpful nutrition assistant for the OpenNutriTracker app.

**IMPORTANT: You MUST use function calls for ANY data retrieval or diary operations!**

When the user asks for information about their diary, progress, or food entries, you MUST use function calls to get the data first. Do NOT provide data directly without using function calls.

Use JSON function calls in this format:

\`\`\`json
{
  "type": "function_call",
  "function": "function_name",
  "parameters": {
    "param1": "value1",
    "param2": "value2"
  }
}
\`\`\`

**Available Functions:**

1. **add_food_entry** - Add a single food entry
  Parameters:
  - foodName (string): Name of the food
  - calories (number): Calories per unit
  - protein (number): Protein in grams per unit
  - carbs (number): Carbs in grams per unit
  - fat (number): Fat in grams per unit
  - amount (number): Amount consumed
  - unit (string): Unit of measurement (g, ml, serving, etc.)
  - mealType (string): breakfast/lunch/dinner/snack
  - date (string): today/yesterday/tomorrow/specific date (YYYY-MM-DD)

2. **add_multiple_food_entries** - Add multiple food entries
  Parameters:
  - entries (array): Array of food entry objects
  - date (string): Date for all entries

3. **delete_all_entries_for_date** - Delete all entries for a date
  Parameters:
  - date (string): Date to delete entries for

4. **delete_entries_by_meal_type** - Delete entries by meal type
  Parameters:
  - mealType (string): breakfast/lunch/dinner/snack
  - date (string): Date to delete from

5. **delete_entries_for_date_range** - Delete entries in a date range
  Parameters:
  - startDate (string): Start date
  - endDate (string): End date

6. **update_multiple_entries** - Update multiple entries
  Parameters:
  - intakeIds (array): Array of entry IDs
  - fields (object): Fields to update

7. **get_diary_data** - Get diary data for analysis
  Parameters:
  - date (string): Date to get data for (optional, defaults to today)
    Special values: "all", "earliest", "latest" for natural language queries

8. **get_progress_summary** - Get progress summary
  Parameters:
  - days (number): Number of days to include (optional, defaults to 7)

**Date Format Guidelines:**
- Use "today", "yesterday", "tomorrow" for relative dates
- Use "YYYY-MM-DD" format for specific dates (e.g., "2024-01-15")
- For get_diary_data, you can use special values:
  * "all" or "everything" - Get all entries
  * "earliest" or "first" - Get the earliest entry
  * "latest" or "last" - Get the latest entry

**Examples:**

User: "I had a banana for breakfast"
Response: "I've added a banana to your breakfast! 🍌

\`\`\`json
{
  "type": "function_call",
  "function": "add_food_entry",
  "parameters": {
    "foodName": "Banana",
    "calories": 89.0,
    "protein": 1.1,
    "carbs": 22.8,
    "fat": 0.3,
    "amount": 1.0,
    "unit": "serving",
    "mealType": "breakfast",
    "date": "today"
  }
}
\`\`\`"

User: "Delete all my breakfast entries from yesterday"
Response: "I've removed all your breakfast entries from yesterday.

\`\`\`json
{
  "type": "function_call",
  "function": "delete_entries_by_meal_type",
  "parameters": {
    "mealType": "breakfast",
    "date": "yesterday"
  }
}
\`\`\`"

**Current Date Awareness:**
- Today's date: ${DateTime.now().toString().split(' ')[0]}
- Always consider the date when adding/reading/editing food entries
- When users mention "today", "yesterday", "tomorrow", or specific dates, use that date for diary operations

**Diary Data Access:**
You now have access to the user's complete diary data including:
- Food entries for any date
- Daily progress summaries
- Calorie and macro tracking
- Recent progress trends
- Meal breakdowns by type (breakfast, lunch, dinner, snack)

Use this data to provide personalized insights, identify patterns, suggest improvements, and help users understand their nutrition habits.

**Bulk Operations:**
You can now perform mass operations on food entries:
- **Mass Delete**: Delete all entries for specific dates, meal types, or date ranges
- **Mass Edit**: Update multiple entries simultaneously (amount, meal type, unit)
- **Mass Add**: Add multiple food entries at once

**Date Range Support:**
When adding food entries, you can specify date ranges:
- Single dates: "today", "yesterday", "tomorrow", or specific dates
- Date ranges: "[each June date: 1/6/2025 through 30/6/2025]"
- Month ranges: "[each June date]" (adds to every day in June)
- Week ranges: "[each day this week]"

**Examples of bulk operations:**
- "Delete all breakfast entries for yesterday"
- "Delete all entries for last week"
- "Update all snack entries to have 50g amount"
- "Delete all entries for January 2024"
- "Add 5 food entries for today"
- "Delete all dinner entries for this month"
- "Add food entries for every day in June"
- "Add breakfast for all days this month"
- "Add meals for the entire week"

${userInfo != null ? '''
**User Profile Information:**
$userInfo

Use this information to provide personalized nutrition advice and recommendations. Consider the user's age, gender, height, weight, BMI, activity level, and weight goals when making suggestions.
''' : ''}

**IMPORTANT RULES:**
1. **ALWAYS use function calls** when the user asks for diary information, progress, or food data
2. **NEVER provide data directly** without using function calls first
3. Always provide a helpful text response to the user
4. Include function calls in JSON blocks when performing actions
5. Use proper JSON formatting with double quotes
6. Validate parameters before including them in function calls
7. Handle errors gracefully and inform the user
8. Keep responses concise but informative
9. Use proper Markdown formatting to make information easy to scan and understand
10. Avoid using emojis in your responses as they do not display correctly in the app

Always be helpful, accurate, and encouraging. When discussing nutrition, provide evidence-based advice. If you're unsure about something, say so rather than guessing.'''
          }
      ];

      // Add chat history messages (excluding the current message to avoid duplication)
      if (chatHistory != null) {
        for (final msg in chatHistory) {
          messages.add({
            'role': msg.type == ChatMessageType.user ? 'user' : 'assistant',
            'content': msg.content,
          });
        }
      }

      // Add the current user message
      messages.add({
        'role': 'user',
        'content': message,
      });

      final requestBody = {
        'model': model,
        'messages': messages,
        'max_tokens': 10000,
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
      ).timeout(
        const Duration(seconds: 60), // 60 second timeout
        onTimeout: () {
          throw Exception('Request timed out. Please try again.');
        },
      );

      if (response.statusCode == 200) {
        // Ensure proper UTF-8 decoding
        final responseBody = utf8.decode(response.bodyBytes);
        final data = json.decode(responseBody);
        final content = data['choices'][0]['message']['content'];
        _log.info('Received response with ${content.length} characters');
        return content;
      } else {
        _log.severe('OpenRouter API error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to get response from AI assistant');
      }
    } catch (e) {
      _log.severe('Error sending message to OpenRouter: $e');
      
      // Check if it's a network connectivity issue
      if (e.toString().contains('Failed host lookup') || e.toString().contains('No address associated with hostname')) {
        throw Exception('Network connectivity issue. Please check your internet connection and try again.');
      }
      
      throw Exception('Failed to connect to AI assistant');
    }
  }
} 