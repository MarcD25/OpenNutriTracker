import 'package:opennutritracker/features/chat/data/data_source/chat_data_source.dart';
import 'package:opennutritracker/features/chat/domain/entity/chat_message_entity.dart';
import 'package:opennutritracker/features/chat/domain/entity/custom_model_entity.dart';
import 'package:opennutritracker/core/utils/id_generator.dart';
import 'package:opennutritracker/core/domain/entity/user_gender_entity.dart';
import 'package:opennutritracker/core/domain/usecase/get_user_usecase.dart';
import 'package:opennutritracker/core/utils/calc/bmi_calc.dart';
import 'package:opennutritracker/features/chat/domain/usecase/ai_food_entry_usecase.dart';
import 'package:logging/logging.dart';

class ChatUsecase {
  final ChatDataSource _chatDataSource;
  final GetUserUsecase _getUserUsecase;
  final AIFoodEntryUsecase _aiFoodEntryUsecase;
  final Logger _log = Logger('ChatUsecase');

  ChatUsecase(this._chatDataSource, this._getUserUsecase, this._aiFoodEntryUsecase);

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

  // Message Handling
  Future<ChatMessageEntity> sendMessage(String message, String apiKey, String model) async {
    final userInfo = await getUserInfoForChat();
    final response = await _chatDataSource.sendMessage(message, apiKey, model, userInfo: userInfo);
    
    // Parse AI response for food entries and add them to diary
    await _parseAndAddFoodEntries(response, message);
    
    final assistantMessage = ChatMessageEntity(
      id: IdGenerator.getUniqueID(),
      content: response,
      type: ChatMessageType.assistant,
      timestamp: DateTime.now(),
    );

    return assistantMessage;
  }

  /// Parses AI response for food entry information and adds to diary
  Future<void> _parseAndAddFoodEntries(String aiResponse, String userMessage) async {
    try {
      _log.info('Parsing AI response for food entries...');
      _log.info('AI Response: ${aiResponse.substring(0, aiResponse.length > 200 ? 200 : aiResponse.length)}...');
      
      // Look for food entry patterns in AI response
      final foodEntryPattern = RegExp(
        r'Food Name:\s*([^\n]+)\s*\n'
        r'Calories:\s*([^\n]+)\s*\n'
        r'Protein:\s*([^\n]+)\s*\n'
        r'Carbs:\s*([^\n]+)\s*\n'
        r'Fat:\s*([^\n]+)\s*\n'
        r'Amount:\s*([^\n]+)\s*\n'
        r'Unit:\s*([^\n]+)\s*\n'
        r'Meal Type:\s*([^\n]+)\s*\n'
        r'Date:\s*([^\n]+)',
        caseSensitive: false,
        multiLine: true,
      );

      final matches = foodEntryPattern.allMatches(aiResponse);
      _log.info('Found ${matches.length} food entry matches in AI response');
      
      for (final match in matches) {
        try {
          final foodName = match.group(1)?.trim() ?? '';
          final calories = double.tryParse(match.group(2)?.trim() ?? '0') ?? 0.0;
          final protein = double.tryParse(match.group(3)?.trim() ?? '0') ?? 0.0;
          final carbs = double.tryParse(match.group(4)?.trim() ?? '0') ?? 0.0;
          final fat = double.tryParse(match.group(5)?.trim() ?? '0') ?? 0.0;
          final amount = double.tryParse(match.group(6)?.trim() ?? '0') ?? 0.0;
          final unit = match.group(7)?.trim() ?? 'g';
          final mealType = match.group(8)?.trim() ?? 'snack';
          final dateString = match.group(9)?.trim() ?? 'today';
          
          _log.info('Parsed food entry: $foodName - ${calories}cal, ${protein}g protein, ${carbs}g carbs, ${fat}g fat, $amount $unit, $mealType, $dateString');
          
          // Parse the date
          DateTime? targetDate;
          if (dateString.toLowerCase() == 'today') {
            targetDate = DateTime.now();
          } else if (dateString.toLowerCase() == 'yesterday') {
            targetDate = DateTime.now().subtract(const Duration(days: 1));
          } else if (dateString.toLowerCase() == 'tomorrow') {
            targetDate = DateTime.now().add(const Duration(days: 1));
          } else {
            targetDate = parseDate(dateString) ?? DateTime.now();
          }

          // Add the food entry
          await addFoodEntry(
            foodName: foodName,
            calories: calories,
            protein: protein,
            carbs: carbs,
            fat: fat,
            amount: amount,
            unit: unit,
            mealType: mealType,
            date: targetDate,
          );
          
          _log.info('Successfully added food entry: $foodName');
        } catch (e) {
          // Log error but continue processing other entries
          _log.severe('Error adding food entry: $e');
        }
      }
    } catch (e) {
      // Log error but don't fail the entire message
      _log.severe('Error parsing food entries: $e');
    }
  }

  ChatMessageEntity createUserMessage(String content) {
    return ChatMessageEntity(
      id: IdGenerator.getUniqueID(),
      content: content,
      type: ChatMessageType.user,
      timestamp: DateTime.now(),
    );
  }

  // User Information for Chat Context
  Future<String> getUserInfoForChat() async {
    try {
      final user = await _getUserUsecase.getUserData();
      final bmi = BMICalc.getBMI(user);
      final bmiStatus = BMICalc.getNutritionalStatus(bmi);
      
      return '''User Profile:
- Age: ${user.age} years old
- Gender: ${user.gender == UserGenderEntity.male ? 'Male' : 'Female'}
- Height: ${user.heightCM.toStringAsFixed(1)} cm
- Weight: ${user.weightKG.toStringAsFixed(1)} kg
- BMI: ${bmi.toStringAsFixed(1)} (${bmiStatus.toString().split('.').last})
- Activity Level: ${user.pal.toString().split('.').last}
- Weight Goal: ${user.goal.toString().split('.').last}''';
    } catch (e) {
      return 'User profile information not available.';
    }
  }

  // AI Food Entry Methods
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
} 