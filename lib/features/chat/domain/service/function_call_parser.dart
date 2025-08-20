import 'dart:convert';
import 'package:logging/logging.dart';
import 'package:opennutritracker/features/chat/domain/entity/function_call_entity.dart';

class FunctionCallParser {
  static final Logger _log = Logger('FunctionCallParser');

  /// Parses JSON function calls from AI response
  /// Returns list of FunctionCallEntity objects found in the response
  static List<FunctionCallEntity> parseFunctionCalls(String response) {
    final List<FunctionCallEntity> functionCalls = [];
    
    try {
      _log.info('Parsing function calls from response...');
      
      // Parse JSON blocks in the response
      final fencedJsonPattern = RegExp(r'```json\s*(\{[\s\S]*?\})\s*```', dotAll: true);
      final fencedAnyPattern = RegExp(r'```\s*(\{[\s\S]*?\})\s*```', dotAll: true);
      final rawFunctionPattern = RegExp(r'(\{[\s\S]*?\})', dotAll: true);
      final seen = <String>{};
      final matches = <RegExpMatch>[];
      matches.addAll(fencedJsonPattern.allMatches(response));
      matches.addAll(fencedAnyPattern.allMatches(response));
      
      _log.info('Found ${matches.length} JSON blocks in response');
      
      for (final match in matches) {
        try {
          final jsonString = match.group(1)!;
          if (seen.contains(jsonString)) continue;
          seen.add(jsonString);
          _log.fine('Parsing JSON block: ${jsonString.substring(0, jsonString.length > 100 ? 100 : jsonString.length)}...');
          
          final dynamic decoded = json.decode(jsonString);
          if (decoded is! Map) continue;
          final Map<String, dynamic> jsonData = decoded.map((k, v) => MapEntry(k.toString(), v));
          
          if (jsonData['type'] == 'function_call') {
            final functionCall = FunctionCallEntity.fromJson(jsonData);
            functionCalls.add(functionCall);
            _log.info('Successfully parsed function call: ${functionCall.function}');
          } else {
            _log.fine('JSON block is not a function call, type: ${jsonData['type']}');
          }
        } catch (e) {
          _log.warning('Error parsing JSON block: $e');
          // Continue parsing other blocks
        }
      }

      // As a fallback, try raw JSON objects in the text (no fences)
      for (final match in rawFunctionPattern.allMatches(response)) {
        try {
          final candidate = match.group(1)!;
          if (candidate.length > 12000) continue; // skip giant blocks
          if (seen.contains(candidate)) continue;
          final dynamic decoded = json.decode(candidate);
          if (decoded is Map && decoded['type'] == 'function_call') {
            final Map<String, dynamic> jsonData = decoded.map((k, v) => MapEntry(k.toString(), v));
            final functionCall = FunctionCallEntity.fromJson(jsonData);
            functionCalls.add(functionCall);
            seen.add(candidate);
          }
        } catch (_) {
          // ignore
        }
      }
      
      _log.info('Successfully parsed ${functionCalls.length} function calls');
      return functionCalls;
    } catch (e) {
      _log.severe('Error parsing function calls: $e');
      return [];
    }
  }

  /// Extracts visible content from AI response by removing JSON blocks
  static String extractVisibleContent(String response) {
    try {
      // Remove JSON blocks and clean up extra whitespace
      var cleanedResponse = response.replaceAll(
        RegExp(r'```json\s*\{[\s\S]*?\}\s*```', dotAll: true),
        '',
      );
      cleanedResponse = cleanedResponse.replaceAll(
        RegExp(r'```\s*\{[\s\S]*?\}\s*```', dotAll: true),
        '',
      ).trim();
      
      // Remove multiple consecutive newlines
      final finalResponse = cleanedResponse.replaceAll(RegExp(r'\n\s*\n\s*\n'), '\n\n');
      
      _log.fine('Extracted visible content: ${finalResponse.length} characters');
      return finalResponse;
    } catch (e) {
      _log.warning('Error extracting visible content: $e');
      return response; // Return original response if extraction fails
    }
  }

  /// Validates function call parameters
  static bool validateFunctionCall(FunctionCallEntity functionCall) {
    try {
      switch (functionCall.function) {
        case 'add_food_entry':
          return _validateAddFoodEntry(functionCall.parameters);
        case 'add_multiple_food_entries':
          return _validateAddMultipleFoodEntries(functionCall.parameters);
        case 'delete_all_entries_for_date':
          return _validateDeleteAllEntriesForDate(functionCall.parameters);
        case 'delete_entries_by_meal_type':
          return _validateDeleteEntriesByMealType(functionCall.parameters);
        case 'delete_entries_for_date_range':
          return _validateDeleteEntriesForDateRange(functionCall.parameters);
        case 'update_multiple_entries':
          return _validateUpdateMultipleEntries(functionCall.parameters);
        default:
          _log.warning('Unknown function: ${functionCall.function}');
          return false;
      }
    } catch (e) {
      _log.severe('Error validating function call: $e');
      return false;
    }
  }

  // Validation methods for different function types
  static bool _validateAddFoodEntry(Map<String, dynamic> params) {
    final requiredFields = ['foodName', 'calories', 'protein', 'carbs', 'fat', 'amount', 'unit', 'mealType'];
    
    for (final field in requiredFields) {
      if (!params.containsKey(field) || params[field] == null) {
        _log.warning('Missing required field: $field');
        return false;
      }
    }
    
    // Validate numeric fields
    final numericFields = ['calories', 'protein', 'carbs', 'fat', 'amount'];
    for (final field in numericFields) {
      final value = params[field];
      if (value is! num || value < 0) {
        _log.warning('Invalid numeric value for $field: $value');
        return false;
      }
    }
    
    // Validate meal type
    final validMealTypes = ['breakfast', 'lunch', 'dinner', 'snack'];
    if (!validMealTypes.contains(params['mealType'])) {
      _log.warning('Invalid meal type: ${params['mealType']}');
      return false;
    }
    
    return true;
  }

  static bool _validateAddMultipleFoodEntries(Map<String, dynamic> params) {
    if (!params.containsKey('entries') || params['entries'] is! List) {
      _log.warning('Missing or invalid entries array');
      return false;
    }
    
    final entries = params['entries'] as List;
    for (final entry in entries) {
      if (entry is! Map<String, dynamic>) {
        _log.warning('Invalid entry format');
        return false;
      }
      
      if (!_validateAddFoodEntry(entry)) {
        return false;
      }
    }
    
    return true;
  }

  static bool _validateDeleteAllEntriesForDate(Map<String, dynamic> params) {
    if (!params.containsKey('date') || params['date'] == null) {
      _log.warning('Missing date parameter');
      return false;
    }
    
    return true;
  }

  static bool _validateDeleteEntriesByMealType(Map<String, dynamic> params) {
    final requiredFields = ['mealType', 'date'];
    
    for (final field in requiredFields) {
      if (!params.containsKey(field) || params[field] == null) {
        _log.warning('Missing required field: $field');
        return false;
      }
    }
    
    // Validate meal type
    final validMealTypes = ['breakfast', 'lunch', 'dinner', 'snack'];
    if (!validMealTypes.contains(params['mealType'])) {
      _log.warning('Invalid meal type: ${params['mealType']}');
      return false;
    }
    
    return true;
  }

  static bool _validateDeleteEntriesForDateRange(Map<String, dynamic> params) {
    final requiredFields = ['startDate', 'endDate'];
    
    for (final field in requiredFields) {
      if (!params.containsKey(field) || params[field] == null) {
        _log.warning('Missing required field: $field');
        return false;
      }
    }
    
    return true;
  }

  static bool _validateUpdateMultipleEntries(Map<String, dynamic> params) {
    if (!params.containsKey('intakeIds') || params['intakeIds'] is! List) {
      _log.warning('Missing or invalid intakeIds array');
      return false;
    }
    
    if (!params.containsKey('fields') || params['fields'] is! Map) {
      _log.warning('Missing or invalid fields object');
      return false;
    }
    
    return true;
  }
} 