import 'package:opennutritracker/features/chat/data/data_source/chat_data_source.dart';
import 'package:opennutritracker/features/chat/domain/entity/chat_message_entity.dart';
import 'package:opennutritracker/features/chat/domain/entity/custom_model_entity.dart';
import 'package:opennutritracker/core/utils/id_generator.dart';
import 'package:opennutritracker/core/domain/entity/user_gender_entity.dart';
import 'package:opennutritracker/core/domain/entity/intake_entity.dart';
import 'package:opennutritracker/core/domain/entity/intake_type_entity.dart';
import 'package:opennutritracker/core/domain/usecase/get_user_usecase.dart';
import 'package:opennutritracker/core/utils/calc/bmi_calc.dart';
import 'package:opennutritracker/features/chat/domain/usecase/ai_food_entry_usecase.dart';
import 'package:opennutritracker/features/chat/domain/usecase/chat_diary_data_usecase.dart';
import 'package:opennutritracker/core/domain/usecase/bulk_intake_operations_usecase.dart';
import 'package:logging/logging.dart';

class ChatUsecase {
  final ChatDataSource _chatDataSource;
  final GetUserUsecase _getUserUsecase;
  final AIFoodEntryUsecase _aiFoodEntryUsecase;
  final ChatDiaryDataUsecase _chatDiaryDataUsecase;
  final BulkIntakeOperationsUsecase _bulkIntakeOperationsUsecase;
  final Logger _log = Logger('ChatUsecase');

  ChatUsecase(this._chatDataSource, this._getUserUsecase, this._aiFoodEntryUsecase, this._chatDiaryDataUsecase, this._bulkIntakeOperationsUsecase);

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
  Future<ChatMessageEntity> sendMessage(String message, String apiKey, String model, {List<ChatMessageEntity>? chatHistory}) async {
    final userInfo = await getUserInfoForChat();
    final response = await _chatDataSource.sendMessage(message, apiKey, model, userInfo: userInfo, chatHistory: chatHistory);
    
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
          
          // Parse the date and handle bulk operations
          final dates = parseDateRange(dateString);
          
          // Add the food entry for each date
          for (final targetDate in dates) {
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
          }
          
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