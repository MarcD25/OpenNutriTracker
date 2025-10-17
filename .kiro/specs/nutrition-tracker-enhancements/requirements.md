# Requirements Document

## Introduction

This document outlines the requirements for enhancing the OpenNutriTracker app with six key features: logistics tracking for performance reviews, LLM response validation, improved table markdown formatting, BMI-specific calorie limits, exercise calorie tracking with net calorie calculation, and weight check-in functionality. These enhancements will improve user experience, data quality, and provide better insights for both users and developers. All features must be compatible with both Android and iOS platforms.

## Requirements

### Requirement 1: Logistics Tracking System

**User Story:** As a developer/researcher, I want to track user interactions and chat outputs in a low-key file system, so that I can conduct performance reviews and analyze test user behavior.

#### Acceptance Criteria

1. WHEN a user interacts with the app THEN the system SHALL log user actions to a local logistics file
2. WHEN the AI chat generates responses THEN the system SHALL record chat outputs with timestamps
3. WHEN users navigate between screens THEN the system SHALL track navigation patterns
4. WHEN users perform key actions (meal logging, exercise entry, weight updates) THEN the system SHALL record these events
5. IF the logistics file exceeds a certain size THEN the system SHALL rotate logs to prevent storage issues
6. WHEN accessing logistics data THEN the system SHALL ensure user privacy and data encryption
7. WHEN implementing on iOS THEN the system SHALL comply with iOS file system restrictions and privacy guidelines

### Requirement 2: LLM Response Validation System

**User Story:** As a user, I want the system to validate AI responses for believability and completeness, so that I receive accurate and reasonable nutrition advice.

#### Acceptance Criteria

1. WHEN the LLM generates a response THEN the system SHALL check if the response size is within reasonable limits
2. WHEN the LLM provides nutrition information THEN the system SHALL validate that all required information is present
3. IF an LLM response is unusually large THEN the system SHALL flag it for review or truncation
4. WHEN the LLM suggests calorie values THEN the system SHALL verify they are within believable ranges
5. IF an LLM response fails validation THEN the system SHALL either request a new response or show an error message
6. WHEN validation occurs THEN the system SHALL log validation results for analysis

### Requirement 3: Enhanced Table Markdown Formatting

**User Story:** As a user, I want to view markdown tables with side-to-side scrolling instead of cramped formatting, so that I can easily read nutritional information and data tables.

#### Acceptance Criteria

1. WHEN markdown tables are displayed THEN the system SHALL render them with horizontal scrolling capability
2. WHEN tables exceed screen width THEN the system SHALL maintain readability without text wrapping
3. WHEN users scroll tables horizontally THEN the system SHALL preserve header visibility when possible
4. WHEN tables contain nutritional data THEN the system SHALL ensure proper column alignment
5. WHEN viewing tables on different screen sizes THEN the system SHALL adapt the display appropriately
6. WHEN running on iOS THEN the system SHALL use iOS-native scrolling behaviors and gestures

### Requirement 4: BMI-Specific Calorie Limits with Exercise Integration

**User Story:** As a user, I want calorie limits that consider my BMI and adjust based on exercise input, so that I receive personalized and accurate daily calorie targets that are consistent across all app functions.

#### Acceptance Criteria

1. WHEN calculating daily calorie goals THEN the system SHALL factor in the user's current BMI
2. WHEN a user's BMI indicates specific health categories THEN the system SHALL apply appropriate calorie adjustments
3. WHEN users log exercise THEN the system SHALL recalculate calorie limits based on activity level
4. IF a user's BMI changes significantly THEN the system SHALL prompt for goal reassessment
5. WHEN displaying calorie goals THEN the system SHALL show both base and exercise-adjusted targets
6. WHEN BMI falls outside healthy ranges THEN the system SHALL provide appropriate guidance
7. WHEN users access calorie deficit/surplus settings THEN the system SHALL provide an easy-to-use function to adjust daily calorie targets by specific amounts
8. WHEN calorie limits are calculated THEN the system SHALL ensure consistency across all app functions and features
9. WHEN users modify their calorie adjustment preferences THEN the system SHALL apply changes uniformly throughout the app

### Requirement 5: Exercise Calorie Tracking with Net Calorie Calculation

**User Story:** As a user, I want to log exercise calories burned so that my net daily calories are automatically updated and I can see my true calorie balance.

#### Acceptance Criteria

1. WHEN users log exercise activities THEN the system SHALL allow input of calories burned (negative kcal)
2. WHEN multiple exercise entries are made per day THEN the system SHALL aggregate total exercise calories
3. WHEN calculating net calories THEN the system SHALL subtract exercise calories from TDEE
4. WHEN displaying daily summary THEN the system SHALL show TDEE, total exercise calories, and net remaining calories
5. WHEN exercise is logged THEN the system SHALL update the daily calorie balance in real-time
6. IF exercise calories seem unrealistic THEN the system SHALL provide validation warnings
7. WHEN integrating with existing meal logging THEN the system SHALL maintain accurate daily totals
8. WHEN users have a calculated TDEE THEN the system SHALL use this value instead of fixed averages

### Requirement 6: Weight Check-in Functionality

**User Story:** As a user, I want to log my weight at user-defined intervals and be reminded to check in, so that I can track my progress over time with clear visual indicators in the Diary tab.

#### Acceptance Criteria

1. WHEN first using the weight check-in feature THEN the system SHALL ask users to set their preferred check-in frequency
2. WHEN the check-in time arrives THEN the system SHALL display a weight entry prompt in the Home/Diary tab
3. WHEN users log their weight THEN the system SHALL store the data with timestamps
4. WHEN users want to change check-in frequency THEN the system SHALL allow editing in settings
5. WHEN weight data is entered THEN the system SHALL update BMI calculations and related calorie goals
6. WHEN viewing weight history THEN the system SHALL display trends and progress charts
7. IF users miss check-ins THEN the system SHALL provide gentle reminders without being intrusive
8. WHEN weight changes significantly THEN the system SHALL suggest reviewing nutrition goals
9. WHEN implementing notifications on iOS THEN the system SHALL request proper permissions and follow iOS notification guidelines
10. WHEN viewing the Diary tab THEN the system SHALL display weight check-in days with specific visual highlights
11. WHEN a day is designated as a check-in day THEN the system SHALL show a clear indicator that distinguishes it from regular days
12. WHEN users set check-in frequency THEN the system SHALL mark appropriate days in the Diary tab according to the selected frequency

### Requirement 7: Consistent Food Entry Hold Function

**User Story:** As a user, I want the same hold function options available for all food entries regardless of which day they are from, so that I have consistent interaction patterns throughout the app.

#### Acceptance Criteria

1. WHEN holding a food entry from today THEN the system SHALL provide the same options as entries from other days
2. WHEN holding any food entry THEN the system SHALL show 'Edit Details', 'Copy to Another Day', and 'Delete' options
3. WHEN selecting 'Copy to Another Day' THEN the system SHALL allow copying to any date including today
4. WHEN holding food entries THEN the system SHALL provide consistent behavior regardless of the entry date
5. WHEN users interact with food entries THEN the system SHALL maintain the same interaction patterns across all diary days
6. WHEN implementing hold functions THEN the system SHALL ensure code consistency and maintainability

### Requirement 8: Home Page Content Cleanup

**User Story:** As a user, I want a cleaner home page without unnecessary BMI warnings and recommendations, so that I can focus on essential daily tracking information.

#### Acceptance Criteria

1. WHEN viewing the Home page THEN the system SHALL NOT display BMI warning messages
2. WHEN viewing the Home page THEN the system SHALL NOT show personalized BMI recommendations
3. WHEN users access the Home page THEN the system SHALL focus on essential daily tracking metrics
4. WHEN BMI-related information is needed THEN the system SHALL make it available through appropriate settings or dedicated screens
5. WHEN cleaning up the Home page THEN the system SHALL maintain all essential functionality while removing clutter