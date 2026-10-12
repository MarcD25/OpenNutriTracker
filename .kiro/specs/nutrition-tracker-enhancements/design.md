# Design Document

## Overview

This design document outlines the technical architecture and implementation approach for six key enhancements to the OpenNutriTracker app. The enhancements include logistics tracking, LLM response validation, improved table markdown formatting, BMI-specific calorie limits, exercise calorie tracking with net calorie calculation, and weight check-in functionality. The design follows the existing Clean Architecture pattern with data/domain/presentation layers and integrates seamlessly with the current BLoC state management and Hive storage systems.

## Architecture

### High-Level Architecture

The enhancements will integrate with the existing architecture:

```
Presentation Layer (BLoC + Widgets)
    ↓
Domain Layer (Use Cases + Entities)
    ↓
Data Layer (Repositories + Data Sources)
    ↓
Storage (Hive + Secure Storage)
```

### New Components Overview

1. **Logistics System**: Background service for tracking user interactions
2. **LLM Validation Service**: Response validation and filtering system
3. **Enhanced Markdown Renderer**: Custom table rendering with horizontal scrolling
4. **BMI Calculator Service**: Enhanced calorie calculation with BMI integration
5. **Exercise Tracking System**: Net calorie calculation with TDEE integration
6. **Weight Check-in System**: Scheduled reminders and progress tracking

## Components and Interfaces

### 1. Logistics Tracking System

#### Data Layer
```dart
// lib/core/data/data_source/logistics_data_source.dart
class LogisticsDataSource {
  Future<void> logUserAction(LogisticsEventEntity event);
  Future<void> logChatInteraction(ChatLogEntity chatLog);
  Future<void> logNavigation(NavigationEventEntity navigation);
  Future<void> rotateLogsIfNeeded();
  Future<List<LogisticsEventEntity>> getLogsByDateRange(DateTime start, DateTime end);
}

// lib/core/data/dbo/logistics_event_dbo.dart
@HiveType(typeId: 20)
class LogisticsEventDBO extends HiveObject {
  @HiveField(0) String id;
  @HiveField(1) String eventType;
  @HiveField(2) String eventData;
  @HiveField(3) DateTime timestamp;
  @HiveField(4) String? userId;
  @HiveField(5) Map<String, dynamic>? metadata;
}
```

#### Domain Layer
```dart
// lib/core/domain/entity/logistics_event_entity.dart
class LogisticsEventEntity {
  final String id;
  final LogisticsEventType eventType;
  final Map<String, dynamic> eventData;
  final DateTime timestamp;
  final String? userId;
  final Map<String, dynamic>? metadata;
}

enum LogisticsEventType {
  mealLogged, exerciseLogged, weightCheckin, chatInteraction,
  screenNavigation, settingsChanged, goalUpdated
}

// lib/core/domain/usecase/logistics_tracking_usecase.dart
class LogisticsTrackingUsecase {
  Future<void> trackUserAction(LogisticsEventType type, Map<String, dynamic> data);
  Future<void> trackChatInteraction(String message, String response, Duration responseTime);
  Future<void> trackNavigation(String fromScreen, String toScreen);
}
```

#### Presentation Layer
```dart
// lib/core/presentation/mixins/logistics_tracking_mixin.dart
mixin LogisticsTrackingMixin {
  void trackAction(LogisticsEventType type, Map<String, dynamic> data);
  void trackScreenView(String screenName);
}
```

### 2. LLM Response Validation System

#### Domain Layer
```dart
// lib/features/chat/domain/service/llm_response_validator.dart
class LLMResponseValidator {
  ValidationResult validateResponse(String response);
  bool isResponseSizeReasonable(String response);
  bool containsRequiredNutritionInfo(String response);
  bool areCalorieValuesRealistic(Map<String, dynamic> nutritionData);
  String truncateIfNeeded(String response);
}

// lib/features/chat/domain/entity/validation_result_entity.dart
class ValidationResult {
  final bool isValid;
  final List<ValidationIssue> issues;
  final String? correctedResponse;
  final ValidationSeverity severity;
}

enum ValidationSeverity { info, warning, error, critical }
enum ValidationIssue { 
  responseTooLarge, missingNutritionInfo, unrealisticCalories,
  incompleteResponse, formatError
}
```

#### Integration with Chat System
```dart
// Enhanced ChatUsecase with validation
class ChatUsecase {
  final LLMResponseValidator _validator;
  
  Future<List<ChatMessageEntity>> sendMessage(String message, String apiKey, String model) async {
    String response = await _chatDataSource.sendMessage(message, apiKey, model);
    
    // Validate response
    final validationResult = _validator.validateResponse(response);
    
    if (!validationResult.isValid && validationResult.severity == ValidationSeverity.critical) {
      // Request new response or show error
      response = await _requestNewResponse(message, apiKey, model);
    } else if (validationResult.correctedResponse != null) {
      response = validationResult.correctedResponse!;
    }
    
    // Log validation results for analysis
    await _logValidationResult(validationResult);
    
    return _processResponse(response);
  }
}
```

### 3. Enhanced Table Markdown Formatting

#### Enhanced Custom Markdown Builder
```dart
// lib/core/presentation/widgets/scrollable_table_builder.dart
class ScrollableTableBuilder extends MarkdownElementBuilder {
  @override
  Widget? visitElementAfter(md.Element element, TextStyle? preferredStyle) {
    if (element.tag == 'table') {
      return Container(
        width: double.infinity,
        constraints: BoxConstraints(
          maxHeight: 400,
          minWidth: MediaQuery.of(context).size.width,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: AlwaysScrollableScrollPhysics(),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            physics: AlwaysScrollableScrollPhysics(),
            child: _buildWideTable(element),
          ),
        ),
      );
    }
    return null;
  }
  
  Widget _buildWideTable(md.Element element) {
    final rows = element.children?.where((e) => e.tag == 'tbody').first.children ?? [];
    final headers = element.children?.where((e) => e.tag == 'thead').first.children?.first.children ?? [];
    
    return DataTable(
      columnSpacing: 20, // Increased spacing
      horizontalMargin: 16,
      headingRowHeight: 56,
      dataRowHeight: 48,
      columns: headers.map((header) => DataColumn(
        label: Container(
          width: 120, // Fixed minimum width for each column
          child: Text(
            header.textContent,
            style: TextStyle(fontWeight: FontWeight.bold),
            overflow: TextOverflow.visible,
          ),
        ),
      )).toList(),
      rows: rows.map((row) => DataRow(
        cells: row.children?.map((cell) => DataCell(
          Container(
            width: 120, // Fixed minimum width for each cell
            child: Text(
              cell.textContent,
              overflow: TextOverflow.visible,
              softWrap: true,
            ),
          ),
        )).toList() ?? [],
      )).toList(),
    );
  }
}

// Alternative implementation using custom table widget
class CustomScrollableTable extends StatelessWidget {
  final List<List<String>> tableData;
  final List<String> headers;
  
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      child: Column(
        children: [
          // Sticky header
          Container(
            height: 50,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: headers.map((header) => Container(
                  width: 150, // Fixed width for readability
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    border: Border.all(color: Colors.grey[400]!),
                  ),
                  child: Text(
                    header,
                    style: TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                )).toList(),
              ),
            ),
          ),
          // Scrollable body
          Expanded(
            child: SingleChildScrollView(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Column(
                  children: tableData.map((row) => Row(
                    children: row.map((cell) => Container(
                      width: 150, // Same fixed width as headers
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Text(
                        cell,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.visible,
                      ),
                    )).toList(),
                  )).toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

#### Enhanced Chat Message Widget with Better Table Handling
```dart
// Enhanced ChatMessageWidget with custom table rendering
class ChatMessageWidget extends StatefulWidget {
  Widget _buildMarkdownContent() {
    // Pre-process content to detect and handle tables
    if (_containsTable(widget.message.content)) {
      return _buildContentWithCustomTables();
    }
    
    return MarkdownBody(
      data: widget.message.content,
      builders: {
        'table': ScrollableTableBuilder(),
      },
      styleSheet: _getCustomMarkdownStyle(),
      selectable: true,
    );
  }
  
  Widget _buildContentWithCustomTables() {
    final parts = _splitContentByTables(widget.message.content);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: parts.map((part) {
        if (part.isTable) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: CustomScrollableTable(
              headers: part.headers,
              tableData: part.rows,
            ),
          );
        } else {
          return MarkdownBody(
            data: part.content,
            styleSheet: _getCustomMarkdownStyle(),
            selectable: true,
          );
        }
      }).toList(),
    );
  }
  
  bool _containsTable(String content) {
    return content.contains('|') && content.contains('---');
  }
  
  List<ContentPart> _splitContentByTables(String content) {
    // Parse markdown content and separate tables from regular text
    // Return list of ContentPart objects indicating whether each part is a table
    final parts = <ContentPart>[];
    final lines = content.split('\n');
    
    List<String> currentTextLines = [];
    List<String> currentTableLines = [];
    bool inTable = false;
    
    for (String line in lines) {
      if (_isTableLine(line)) {
        if (!inTable) {
          // Starting a table, save any accumulated text
          if (currentTextLines.isNotEmpty) {
            parts.add(ContentPart(
              content: currentTextLines.join('\n'),
              isTable: false,
            ));
            currentTextLines.clear();
          }
          inTable = true;
        }
        currentTableLines.add(line);
      } else {
        if (inTable) {
          // Ending a table, save the table
          parts.add(_parseTablePart(currentTableLines));
          currentTableLines.clear();
          inTable = false;
        }
        currentTextLines.add(line);
      }
    }
    
    // Handle remaining content
    if (currentTableLines.isNotEmpty) {
      parts.add(_parseTablePart(currentTableLines));
    }
    if (currentTextLines.isNotEmpty) {
      parts.add(ContentPart(
        content: currentTextLines.join('\n'),
        isTable: false,
      ));
    }
    
    return parts;
  }
  
  bool _isTableLine(String line) {
    return line.trim().startsWith('|') || line.contains('---');
  }
  
  ContentPart _parseTablePart(List<String> tableLines) {
    final headers = <String>[];
    final rows = <List<String>>[];
    
    for (int i = 0; i < tableLines.length; i++) {
      final line = tableLines[i].trim();
      if (line.contains('---')) continue; // Skip separator line
      
      final cells = line.split('|')
          .map((cell) => cell.trim())
          .where((cell) => cell.isNotEmpty)
          .toList();
      
      if (headers.isEmpty) {
        headers.addAll(cells);
      } else {
        rows.add(cells);
      }
    }
    
    return ContentPart(
      content: '',
      isTable: true,
      headers: headers,
      rows: rows,
    );
  }
}

class ContentPart {
  final String content;
  final bool isTable;
  final List<String> headers;
  final List<List<String>> rows;
  
  ContentPart({
    required this.content,
    required this.isTable,
    this.headers = const [],
    this.rows = const [],
  });
}
```

### 4. BMI-Specific Calorie Limits

#### Enhanced Calorie Calculation with Consistent Limits
```dart
// lib/core/utils/calc/enhanced_calorie_goal_calc.dart
class EnhancedCalorieGoalCalc {
  static double calculateBMIAdjustedTDEE(UserEntity user, double exerciseCalories) {
    final baseTDEE = CalorieGoalCalc.getTDEE(user);
    final bmi = BMICalc.getBMI(user);
    final bmiAdjustment = _getBMIAdjustmentFactor(bmi, user.goal);
    final exerciseAdjustment = exerciseCalories;
    final userCalorieAdjustment = _getUserCalorieAdjustment(user);
    
    return (baseTDEE * bmiAdjustment) + exerciseAdjustment + userCalorieAdjustment;
  }
  
  static double _getBMIAdjustmentFactor(double bmi, UserWeightGoalEntity goal) {
    // BMI-based adjustments:
    // Underweight (BMI < 18.5): +5-10% calories
    // Normal (18.5-24.9): Standard calculation
    // Overweight (25-29.9): -5% for weight loss goals
    // Obese (BMI >= 30): -10-15% for weight loss goals
  }
  
  static double _getUserCalorieAdjustment(UserEntity user) {
    // Apply user-defined calorie deficit/surplus from settings
    // This ensures consistency across all app functions
    return user.calorieAdjustment ?? 0.0;
  }
  
  static CalorieRecommendation getPersonalizedRecommendation(UserEntity user, double exerciseCalories) {
    return CalorieRecommendation(
      baseTDEE: calculateBaseTDEE(user),
      exerciseCalories: exerciseCalories,
      bmiAdjustment: getBMIAdjustment(user),
      userAdjustment: _getUserCalorieAdjustment(user),
      netCalories: calculateNetCalories(user, exerciseCalories),
      recommendations: generateRecommendations(user)
    );
  }
  
  // New method for easy calorie adjustment access
  static void updateUserCalorieAdjustment(UserEntity user, double adjustment) {
    // Update user's calorie adjustment setting
    // Ensure this change propagates to all calorie calculations
  }
}
```

#### New Entity for Calorie Recommendations
```dart
// lib/core/domain/entity/calorie_recommendation_entity.dart
class CalorieRecommendation {
  final double baseTDEE;
  final double exerciseCalories;
  final double bmiAdjustment;
  final double netCalories;
  final List<String> recommendations;
  final BMICategory bmiCategory;
}

enum BMICategory { underweight, normal, overweight, obese }
```

### 5. Exercise Calorie Tracking with Net Calorie Calculation

#### Enhanced User Activity System
```dart
// lib/core/domain/entity/enhanced_user_activity_entity.dart
class EnhancedUserActivityEntity extends UserActivityEntity {
  final double caloriesBurned;
  final bool isManualCalorieEntry;
  final ActivityIntensity intensity;
  final Map<String, dynamic>? additionalMetrics;
  
  // Net calorie impact calculation
  double get netCalorieImpact => caloriesBurned * -1; // Negative for burned calories
}

enum ActivityIntensity { light, moderate, vigorous, extreme }
```

#### Enhanced Home Bloc with Net Calorie Calculation
```dart
// Enhanced HomeBloc
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  @override
  Stream<HomeState> mapEventToState(HomeEvent event) async* {
    if (event is LoadItemsEvent) {
      // Calculate net calories
      final totalKcalIntake = getTotalKcalIntake();
      final totalExerciseCalories = getTotalExerciseCalories();
      final userTDEE = await _getEnhancedTDEE();
      final netCalories = userTDEE + totalExerciseCalories - totalKcalIntake;
      
      yield HomeLoadedState(
        // ... existing fields
        totalKcalBurned: totalExerciseCalories,
        netKcalRemaining: netCalories,
        tdeeWithExercise: userTDEE + totalExerciseCalories,
      );
    }
  }
  
  Future<double> _getEnhancedTDEE() async {
    final user = await _getUserUsecase.getUserData();
    final todayExercise = await _getTodayExerciseCalories();
    return EnhancedCalorieGoalCalc.calculateBMIAdjustedTDEE(user, todayExercise);
  }
}
```

#### Exercise Calorie Input Widget
```dart
// lib/features/add_activity/presentation/widgets/exercise_calorie_input_widget.dart
class ExerciseCalorieInputWidget extends StatefulWidget {
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Duration input
        DurationInputField(),
        // Automatic calorie calculation based on MET values
        AutoCalculatedCaloriesDisplay(),
        // Manual calorie override option
        ManualCalorieInputField(),
        // Intensity selector
        IntensitySelector(),
        // Validation warnings for unrealistic values
        CalorieValidationWarning(),
      ],
    );
  }
}
```

### 6. Weight Check-in Functionality

#### Weight Check-in Data Layer
```dart
// lib/features/weight_checkin/data/data_source/weight_checkin_data_source.dart
class WeightCheckinDataSource {
  Future<void> saveWeightEntry(WeightEntryDBO weightEntry);
  Future<List<WeightEntryDBO>> getWeightHistory(DateTime? startDate, DateTime? endDate);
  Future<WeightEntryDBO?> getLatestWeightEntry();
  Future<void> setCheckinFrequency(CheckinFrequency frequency);
  Future<CheckinFrequency> getCheckinFrequency();
  Future<DateTime?> getNextCheckinDate();
}

// lib/features/weight_checkin/data/dbo/weight_entry_dbo.dart
@HiveType(typeId: 21)
class WeightEntryDBO extends HiveObject {
  @HiveField(0) String id;
  @HiveField(1) double weightKG;
  @HiveField(2) DateTime timestamp;
  @HiveField(3) String? notes;
  @HiveField(4) double? bodyFatPercentage;
  @HiveField(5) double? muscleMass;
}
```

#### Domain Layer
```dart
// lib/features/weight_checkin/domain/entity/weight_entry_entity.dart
class WeightEntryEntity {
  final String id;
  final double weightKG;
  final DateTime timestamp;
  final String? notes;
  final double? bodyFatPercentage;
  final double? muscleMass;
  
  // Calculated properties
  double get weightLbs => weightKG * 2.20462;
  BMICategory get bmiCategory => BMICalc.getBMICategory(bmi);
}

enum CheckinFrequency { daily, weekly, biweekly, monthly }

// lib/features/weight_checkin/domain/usecase/weight_checkin_usecase.dart
class WeightCheckinUsecase {
  Future<void> recordWeightEntry(double weight, String? notes);
  Future<List<WeightEntryEntity>> getWeightHistory(int days);
  Future<WeightTrend> calculateWeightTrend(int days);
  Future<bool> shouldShowCheckinReminder();
  Future<void> scheduleNextCheckin();
}
```

#### Presentation Layer
```dart
// lib/features/weight_checkin/presentation/widgets/weight_checkin_card.dart
class WeightCheckinCard extends StatelessWidget {
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          WeightInputField(),
          TrendIndicator(),
          BMIUpdateNotification(),
          GoalAdjustmentSuggestion(),
        ],
      ),
    );
  }
}

// lib/features/weight_checkin/presentation/widgets/weight_progress_chart.dart
class WeightProgressChart extends StatelessWidget {
  // Chart showing weight trends over time
  // Integration with existing chart libraries
  // Support for different time ranges (week, month, year)
}
```

#### Integration with Home Screen and Diary
```dart
// Enhanced HomePage with weight check-in integration and cleanup
class HomePage extends StatefulWidget {
  Widget _buildWeightCheckinSection() {
    return BlocBuilder<WeightCheckinBloc, WeightCheckinState>(
      builder: (context, state) {
        if (state.shouldShowCheckin) {
          return WeightCheckinCard(
            onWeightSubmitted: (weight) {
              // Update user profile
              // Recalculate BMI and calorie goals
              // Show progress feedback
            },
          );
        }
        return SizedBox.shrink();
      },
    );
  }
  
  // Remove BMI warnings and recommendations from home page
  Widget _buildCleanDashboard() {
    return Column(
      children: [
        // Essential daily tracking metrics only
        CalorieProgressWidget(),
        MacronutrientSummaryWidget(),
        ActivitySummaryWidget(),
        // Remove: BMIWarningWidget(), BMIRecommendationsWidget()
      ],
    );
  }
}

// Enhanced DiaryPage with weight check-in indicators
class DiaryPage extends StatefulWidget {
  Widget _buildDayIndicator(DateTime date, bool isCheckinDay) {
    return Container(
      decoration: BoxDecoration(
        border: isCheckinDay ? Border.all(color: Colors.blue, width: 2) : null,
        borderRadius: BorderRadius.circular(8),
        color: isCheckinDay ? Colors.blue.withOpacity(0.1) : null,
      ),
      child: Column(
        children: [
          Text(DateFormat('dd').format(date)),
          if (isCheckinDay) 
            Icon(Icons.scale, size: 16, color: Colors.blue),
        ],
      ),
    );
  }
  
  bool _isCheckinDay(DateTime date, CheckinFrequency frequency) {
    // Calculate if the given date should show check-in indicator
    // based on user's selected frequency
    switch (frequency) {
      case CheckinFrequency.daily:
        return true;
      case CheckinFrequency.weekly:
        return date.weekday == 1; // Monday
      case CheckinFrequency.biweekly:
        return _isBiweeklyCheckinDay(date);
      case CheckinFrequency.monthly:
        return date.day == 1;
    }
  }
}
```

## Data Models

### Enhanced User Entity
```dart
class EnhancedUserEntity extends UserEntity {
  final List<WeightEntryEntity> weightHistory;
  final CheckinFrequency weightCheckinFrequency;
  final DateTime? lastWeightCheckin;
  final DateTime? nextWeightCheckin;
  
  // Calculated properties
  double get currentBMI => BMICalc.getBMI(this);
  BMICategory get bmiCategory => BMICalc.getBMICategory(currentBMI);
  WeightTrend get recentWeightTrend => calculateTrend(weightHistory.take(30));
}
```

### Net Calorie Calculation Entity
```dart
class NetCalorieCalculation {
  final double baseTDEE;
  final double bmiAdjustment;
  final double exerciseCalories;
  final double foodCalories;
  final double netCalories;
  final List<CalorieRecommendation> recommendations;
  
  bool get isInDeficit => netCalories < 0;
  bool get isInSurplus => netCalories > 0;
  double get deficitSurplusAmount => netCalories.abs();
}
```

## Error Handling

### Validation Error Handling
```dart
class ValidationException implements Exception {
  final String message;
  final ValidationSeverity severity;
  final List<ValidationIssue> issues;
  
  ValidationException(this.message, this.severity, this.issues);
}

class ErrorHandlingService {
  static void handleValidationError(ValidationException error) {
    switch (error.severity) {
      case ValidationSeverity.critical:
        // Show error dialog, prevent action
        break;
      case ValidationSeverity.error:
        // Show warning, allow user to proceed
        break;
      case ValidationSeverity.warning:
        // Show subtle warning indicator
        break;
      case ValidationSeverity.info:
        // Log for analytics only
        break;
    }
  }
}
```

### Graceful Degradation
- If logistics tracking fails, continue normal app operation
- If LLM validation fails, show original response with warning
- If BMI calculation fails, fall back to standard TDEE calculation
- If weight check-in reminder fails, allow manual entry

## Testing Strategy

### Unit Tests
```dart
// Test files structure:
// test/unit_test/core/utils/calc/enhanced_calorie_goal_calc_test.dart
// test/unit_test/features/weight_checkin/domain/usecase/weight_checkin_usecase_test.dart
// test/unit_test/features/chat/domain/service/llm_response_validator_test.dart

class EnhancedCalorieGoalCalcTest {
  void testBMIAdjustmentCalculation() {
    // Test BMI-based calorie adjustments
    // Test edge cases (very low/high BMI)
    // Test different goal combinations
  }
  
  void testNetCalorieCalculation() {
    // Test exercise calorie integration
    // Test TDEE calculation with exercise
    // Test validation of unrealistic values
  }
}
```

### Integration Tests
```dart
// test/integration_test/weight_checkin_flow_test.dart
class WeightCheckinFlowTest {
  void testCompleteWeightCheckinFlow() {
    // Test weight entry
    // Test BMI recalculation
    // Test calorie goal adjustment
    // Test progress tracking
  }
}

// test/integration_test/exercise_calorie_tracking_test.dart
class ExerciseCalorieTrackingTest { 
  void testExerciseCalorieIntegration() {
    // Test exercise logging
    // Test net calorie calculation
    // Test dashboard updates
    // Test historical data
  }
}
```

### Widget Tests
```dart
// test/widget_test/features/weight_checkin/presentation/widgets/weight_checkin_card_test.dart
class WeightCheckinCardTest {
  void testWeightInputValidation() {
    // Test input validation
    // Test error states
    // Test success states
  }
}
```

### 7. Consistent Food Entry Hold Function

#### Unified Food Entry Actions
```dart
// lib/features/diary/presentation/widgets/food_entry_actions.dart
class FoodEntryActions {
  static List<FoodEntryAction> getAvailableActions(FoodEntryEntity entry, DateTime entryDate) {
    // Return consistent actions regardless of entry date
    return [
      FoodEntryAction.editDetails,
      FoodEntryAction.copyToAnotherDay,
      FoodEntryAction.delete,
    ];
  }
  
  static void handleAction(FoodEntryAction action, FoodEntryEntity entry, BuildContext context) {
    switch (action) {
      case FoodEntryAction.editDetails:
        _showEditDialog(entry, context);
        break;
      case FoodEntryAction.copyToAnotherDay:
        _showDatePicker(entry, context);
        break;
      case FoodEntryAction.delete:
        _confirmDelete(entry, context);
        break;
    }
  }
  
  static void _showDatePicker(FoodEntryEntity entry, BuildContext context) {
    // Allow copying to any date, including today
    showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(Duration(days: 365)),
      lastDate: DateTime.now().add(Duration(days: 365)),
    ).then((selectedDate) {
      if (selectedDate != null) {
        _copyEntryToDate(entry, selectedDate);
      }
    });
  }
}

enum FoodEntryAction { editDetails, copyToAnotherDay, delete }
```

#### Enhanced Food Entry Widget
```dart
// lib/features/diary/presentation/widgets/food_entry_widget.dart
class FoodEntryWidget extends StatelessWidget {
  final FoodEntryEntity entry;
  final DateTime entryDate;
  
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () => _showActionSheet(context),
      child: // ... existing food entry UI
    );
  }
  
  void _showActionSheet(BuildContext context) {
    final actions = FoodEntryActions.getAvailableActions(entry, entryDate);
    
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: actions.map((action) => ListTile(
          leading: _getActionIcon(action),
          title: Text(_getActionTitle(action)),
          onTap: () {
            Navigator.pop(context);
            FoodEntryActions.handleAction(action, entry, context);
          },
        )).toList(),
      ),
    );
  }
  
  IconData _getActionIcon(FoodEntryAction action) {
    switch (action) {
      case FoodEntryAction.editDetails:
        return Icons.edit;
      case FoodEntryAction.copyToAnotherDay:
        return Icons.copy;
      case FoodEntryAction.delete:
        return Icons.delete;
    }
  }
  
  String _getActionTitle(FoodEntryAction action) {
    switch (action) {
      case FoodEntryAction.editDetails:
        return 'Edit Details';
      case FoodEntryAction.copyToAnotherDay:
        return 'Copy to Another Day';
      case FoodEntryAction.delete:
        return 'Delete';
    }
  }
}
```

### 8. Home Page Content Cleanup

#### Simplified Home Page Architecture
```dart
// lib/features/home/presentation/widgets/simplified_dashboard_widget.dart
class SimplifiedDashboardWidget extends StatelessWidget {
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Essential metrics only
        CalorieProgressCard(),
        MacronutrientBreakdownCard(),
        TodayActivitySummaryCard(),
        WeightCheckinCard(), // Only when check-in is due
        // Removed: BMIWarningWidget, BMIRecommendationsWidget
      ],
    );
  }
}

// lib/features/home/presentation/widgets/calorie_progress_card.dart
class CalorieProgressCard extends StatelessWidget {
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        if (state is HomeLoadedState) {
          return Card(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  Text('Daily Calories', style: Theme.of(context).textTheme.headline6),
                  CircularProgressIndicator(
                    value: state.calorieProgress,
                    backgroundColor: Colors.grey[300],
                  ),
                  Text('${state.consumedCalories} / ${state.targetCalories}'),
                  if (state.netKcalRemaining != null)
                    Text('Net remaining: ${state.netKcalRemaining}'),
                ],
              ),
            ),
          );
        }
        return SizedBox.shrink();
      },
    );
  }
}
```

#### Settings Enhancement for Calorie Adjustment
```dart
// lib/features/settings/presentation/widgets/calorie_adjustment_widget.dart
class CalorieAdjustmentWidget extends StatefulWidget {
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Daily Calorie Adjustment', 
                 style: Theme.of(context).textTheme.subtitle1),
            Text('Add or subtract calories from your daily target',
                 style: Theme.of(context).textTheme.caption),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    decoration: InputDecoration(
                      labelText: 'Calorie Adjustment',
                      suffixText: 'kcal',
                      helperText: 'Positive for surplus, negative for deficit',
                    ),
                    keyboardType: TextInputType.numberWithOptions(signed: true),
                    onChanged: (value) => _updateCalorieAdjustment(value),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8),
            Text('Current adjustment: ${_getCurrentAdjustment()} kcal',
                 style: Theme.of(context).textTheme.caption),
          ],
        ),
      ),
    );
  }
  
  void _updateCalorieAdjustment(String value) {
    final adjustment = double.tryParse(value) ?? 0.0;
    // Update user's calorie adjustment setting
    // This will propagate to all calorie calculations
    context.read<SettingsBloc>().add(
      UpdateCalorieAdjustmentEvent(adjustment)
    );
  }
}
```

## Platform-Specific Considerations

### iOS Specific
- Use iOS native scrolling behaviors for table scrolling
- Implement iOS notification permissions for weight check-in reminders
- Follow iOS file system guidelines for logistics data storage
- Use iOS-specific date/time pickers for weight entry

### Android Specific
- Implement Android notification channels for reminders
- Use Android-specific storage permissions
- Follow Material Design guidelines for new UI components

### Cross-Platform
- Use Flutter's platform-aware widgets where appropriate
- Implement responsive design for different screen sizes
- Ensure consistent behavior across platforms while respecting platform conventions

## Performance Considerations

### Logistics Tracking
- Implement efficient batching for log writes
- Use background isolates for heavy logging operations
- Implement log rotation to prevent storage bloat

### LLM Response Validation
- Cache validation results for similar responses
- Implement timeout handling for validation operations
- Use efficient string processing algorithms

### Weight Data Processing
- Implement efficient chart rendering for large datasets
- Use pagination for historical weight data
- Cache calculated trends and statistics

### Memory Management
- Implement proper disposal of controllers and streams
- Use efficient data structures for large datasets
- Implement lazy loading for historical data

This design provides a comprehensive foundation for implementing all six enhancement features while maintaining the existing architecture patterns and ensuring cross-platform compatibility.