# Implementation Plan

- [x] 1. Set up logistics tracking data models and storage





  - Create LogisticsEventDBO with Hive annotations (typeId: 20)
  - Implement LogisticsDataSource for local storage operations
  - Add logistics box initialization to HiveDBProvider
  - Create LogisticsEventEntity and related enums
  - _Requirements: 1.1, 1.2, 1.5_

- [x] 2. Implement logistics tracking system




  - Create LogisticsTrackingUsecase for event logging
  - Implement LogisticsTrackingMixin for easy integration across screens
  - Add log rotation mechanism when files exceed size limits
  - Implement data encryption for sensitive logistics data
  - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5, 1.6, 1.7_

- [x] 3. Integrate logistics tracking into existing screens





  - Add tracking to HomePage for meal and activity logging
  - Add tracking to ChatScreen for AI interactions
  - Add tracking to DiaryPage for navigation patterns
  - Add tracking to SettingsScreen for configuration changes
  - _Requirements: 1.1, 1.2, 1.3, 1.4_

- [x] 4. Implement LLM response validation system





  - Create LLMResponseValidator service class
  - Implement ValidationResult entity and related enums
  - Create response size and content validation methods
  - Add ValidationException for error handling
  - _Requirements: 2.1, 2.2, 2.3, 2.4_

- [x] 5. Integrate validation into ChatUsecase




  - Modify sendMessage method to include response validation
  - Implement validation result logging for analysis
  - Add retry mechanism for failed validations
  - Create user-friendly error handling for validation failures
  - _Requirements: 2.1, 2.2, 2.5, 2.6_

- [x] 6. Add validation feedback UI components




  - Create validation warning indicators in chat interface
  - Implement retry buttons for failed validations
  - Add debug information display for validation results
  - _Requirements: 2.5, 2.6_

- [x] 7. Enhance table markdown formatting




  - Create ScrollableTableBuilder extending MarkdownElementBuilder
  - Implement horizontal and vertical scrolling for tables
  - Add sticky header functionality for better usability
  - Modify ChatMessageWidget to use custom table builder
  - _Requirements: 3.1, 3.2, 3.4, 3.5, 3.6_

- [x] 8. Implement BMI-specific calorie calculation system




  - Create EnhancedCalorieGoalCalc utility class
  - Implement BMI adjustment factors for different categories
  - Create CalorieRecommendation entity with personalized suggestions
  - Modify GetKcalGoalUsecase to use enhanced calculations
  - _Requirements: 4.1, 4.2, 4.5, 4.6_

- [x] 9. Update HomeBloc for BMI-adjusted calorie goals




  - Integrate BMI calculations into existing calorie system
  - Add BMI category indicators in user interface
  - Implement goal reassessment prompts for BMI changes
  - _Requirements: 4.1, 4.2, 4.3, 4.4, 4.6_

- [x] 10. Enhance exercise calorie tracking with net calculation




  - Update HomeBloc to calculate and display net calories (TDEE + exercise - food)
  - Modify home state to include net calorie remaining
  - Ensure integration with existing meal logging system
  - Implement real-time updates when exercise is logged
  - _Requirements: 5.2, 5.3, 5.4, 5.5, 5.7, 5.8_

- [x] 11. Add exercise calorie input enhancements




  - Enhance ActivityDetailScreen to show calorie input options
  - Add calorie validation warnings for unrealistic values
  - Create intensity selector for different activity levels
  - Implement auto-calculation display with manual override option
  - _Requirements: 5.1, 5.6, 5.8_

- [x] 12. Set up weight check-in data models and storage




  - Create WeightEntryDBO with Hive annotations (typeId: 21)
  - Implement WeightCheckinDataSource for weight data operations
  - Add weight tracking box initialization to HiveDBProvider
  - Create WeightEntryEntity and CheckinFrequency enum
  - _Requirements: 6.2, 6.5, 6.6_

- [x] 13. Implement weight check-in functionality




  - Create WeightCheckinUsecase for weight management operations
  - Implement weight trend calculation algorithms
  - Create weight check-in UI components (WeightCheckinCard)
  - Add weight input validation and unit conversion
  - _Requirements: 6.1, 6.2, 6.5, 6.6, 6.8_

- [x] 14. Integrate weight check-in into home screen




  - Modify HomePage to show weight check-in prompts
  - Implement check-in frequency settings in SettingsScreen
  - Create goal adjustment suggestions based on weight changes
  - Implement BMI update notifications
  - _Requirements: 6.1, 6.3, 6.4, 6.7, 6.8, 6.9_

- [x] 15. Implement cross-platform notification system




  - Create notification service for weight check-in reminders
  - Implement iOS notification permission requests
  - Add Android notification channel configuration
  - Create gentle reminder system without being intrusive
  - _Requirements: 6.7, 6.9_

- [x] 16. Update dependency injection and service registration




  - Register all new use cases in locator.dart
  - Add new BLoCs for weight check-in and enhanced features
  - Register new data sources and repositories
  - Update service initialization order
  - _Requirements: All requirements - infrastructure support_

- [x] 17. Create comprehensive error handling





  - Implement ValidationException and error handling service
  - Add graceful degradation for failed features
  - Create user-friendly error messages and recovery options
  - Implement logging for debugging and analytics
  - _Requirements: 2.5, 2.6, 4.4, 5.6, 6.7_

- [x] 18. Integration testing and validation




  - Test complete weight check-in flow with BMI recalculation
  - Validate exercise calorie tracking with net calorie updates
  - Test LLM validation with various response types
  - Verify logistics tracking across all user interactions
  - Test enhanced table rendering with different data sets
  - _Requirements: All requirements - validation_

- [x] 18.1 Create unit tests for core calculations













  - Write tests for EnhancedCalorieGoalCalc BMI adjustments
  - Test weight trend calculations and validation
  - Test LLM response validation logic
  - Test logistics event creation and storage
  - _Requirements: All requirements - testing_

- [x] 18.2 Create widget tests for new UI components






  - Test WeightCheckinCard input validation and display
  - Test enhanced table scrolling behavior
  - Test validation warning displays in chat
  - _Requirements: All requirements - UI testing_

- [x] 19. Performance optimization and cleanup




  - Implement efficient batching for logistics data writes
  - Optimize chart rendering for large weight history datasets
  - Add caching for frequently calculated values
  - Implement proper memory management for new features
  - _Requirements: All requirements - performance_

- [x] 20. Documentation and final integration









  - Update README with new feature descriptions
  - Create user documentation for new functionality
  - Update API documentation for new use cases
  - Perform final integration testing across all platforms
  - _Requirements: All requirements - documentation_

- [x] 21. Fix calorie limit consistency and settings integration





  - Update EnhancedCalorieGoalCalc to include user-defined calorie adjustments
  - Enhance settings screen with easy-to-use calorie adjustment widget
  - Ensure calorie adjustment setting propagates to all app functions
  - Integrate user calorie adjustment with BMI-based calculations
  - Test consistency across home page, diary, and activity screens
  - _Requirements: 4.7, 4.8, 4.9_

- [x] 22. Implement weight check-in visibility in Diary tab




  - Add visual indicators for check-in days in DiaryPage
  - Implement check-in day calculation based on user frequency settings
  - Create distinctive highlighting for check-in days (border, icon, color)
  - Ensure indicators update when user changes check-in frequency
  - Test visual indicators across different screen sizes
  - _Requirements: 6.10, 6.11, 6.12_

- [x] 23. Fix food entry hold function consistency




  - Analyze current food entry hold function implementations
  - Create unified FoodEntryActions class for consistent behavior
  - Update food entry widgets to use consistent action options
  - Rename 'Copy to Today' to 'Copy to Another Day' with date picker
  - Ensure same hold options available for all food entries regardless of date
  - Test hold function consistency across all diary days
  - _Requirements: 7.1, 7.2, 7.3, 7.4, 7.5, 7.6_

- [x] 24. Remove BMI warnings and recommendations from Home page




  - Remove BMIWarningWidget from home page layout
  - Remove BMIRecommendationsWidget from home page
  - Clean up home page to focus on essential daily tracking metrics
  - Ensure BMI information remains accessible through settings or dedicated screens
  - Test home page layout after cleanup
  - _Requirements: 8.1, 8.2, 8.3, 8.4, 8.5_

- [x] 25. Enhance markdown table rendering in chat





  - Implement comprehensive table parsing for markdown content
  - Create CustomScrollableTable widget with fixed column widths
  - Add proper horizontal and vertical scrolling with adequate spacing
  - Implement sticky headers for better table navigation
  - Update ChatMessageWidget to use enhanced table rendering
  - Test table rendering with various table sizes and content
  - _Requirements: 3.1, 3.2, 3.3, 3.4, 3.5, 3.6_

- [x] 26. Integration testing for new fixes





  - Test calorie limit consistency across all app features
  - Verify weight check-in indicators appear correctly in Diary tab
  - Test food entry hold function consistency across different days
  - Verify home page cleanup maintains essential functionality
  - Test enhanced table rendering with various markdown tables
  - Perform cross-platform testing for all fixes
  - _Requirements: All new requirements - validation_