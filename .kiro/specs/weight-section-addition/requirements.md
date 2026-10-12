# Requirements Document

## Introduction

This feature adds a dedicated Weight section to both the Home and Diary pages, positioned after the Snacks section. Users can optionally add their weight for tracking purposes directly from these pages, providing a more convenient way to log weight without navigating to a separate screen.

## Requirements

### Requirement 1: Weight Section in Home Page

**User Story:** As a user, I want to see a Weight section on the Home page after the Snacks section, so that I can quickly log my weight for today.

#### Acceptance Criteria

1. WHEN the user views the Home page THEN the system SHALL display sections in this order: Activity, Breakfast, Lunch, Dinner, Snacks, Weight
2. WHEN the Weight section is displayed AND no weight has been logged for today THEN the system SHALL show a prompt to add weight
3. WHEN the Weight section is displayed AND weight has been logged for today THEN the system SHALL display the logged weight value with unit (kg or lbs based on user settings)
4. WHEN the user taps on the Weight section THEN the system SHALL allow the user to add or edit their weight for today
5. WHEN the user adds or edits weight THEN the system SHALL validate the input and save it to the database
6. WHEN weight is successfully saved THEN the system SHALL update the display immediately without requiring a page refresh

### Requirement 2: Weight Section in Diary Page

**User Story:** As a user, I want to see a Weight section on the Diary page after the Snacks section, so that I can log my weight for any selected date.

#### Acceptance Criteria

1. WHEN the user views the Diary page THEN the system SHALL display sections in this order: Activity, Breakfast, Lunch, Dinner, Snacks, Weight
2. WHEN the Weight section is displayed AND no weight has been logged for the selected date THEN the system SHALL show a prompt to add weight
3. WHEN the Weight section is displayed AND weight has been logged for the selected date THEN the system SHALL display the logged weight value with unit
4. WHEN the user taps on the Weight section THEN the system SHALL allow the user to add or edit weight for the currently selected date
5. WHEN the user adds or edits weight THEN the system SHALL validate the input and save it for the selected date
6. WHEN weight is successfully saved THEN the system SHALL update the display immediately

### Requirement 3: Weight Input Validation

**User Story:** As a user, I want the system to validate my weight input, so that I don't accidentally enter invalid data.

#### Acceptance Criteria

1. WHEN the user enters a weight value THEN the system SHALL accept only numeric values with up to 2 decimal places
2. WHEN the user enters a weight value THEN the system SHALL enforce minimum value of 20 kg (44 lbs) and maximum value of 500 kg (1100 lbs)
3. WHEN the user enters an invalid weight value THEN the system SHALL display an error message explaining the valid range
4. WHEN the user cancels weight input THEN the system SHALL not save any changes and return to the previous view

### Requirement 4: Optional Weight Tracking

**User Story:** As a user, I want weight tracking to be optional, so that I can choose whether or not to log my weight.

#### Acceptance Criteria

1. WHEN the Weight section is displayed THEN the system SHALL clearly indicate that weight logging is optional
2. WHEN the user has not logged weight for a date THEN the system SHALL not show any warnings or errors
3. WHEN the user views historical data THEN the system SHALL display weight data only for dates where weight was logged
4. WHEN the user deletes a weight entry THEN the system SHALL remove it from the database and update the display

### Requirement 5: Unit Consistency

**User Story:** As a user, I want weight to be displayed in my preferred unit system, so that it's consistent with my other measurements.

#### Acceptance Criteria

1. WHEN the user has metric units enabled THEN the system SHALL display weight in kilograms (kg)
2. WHEN the user has imperial units enabled THEN the system SHALL display weight in pounds (lbs)
3. WHEN the user changes their unit preference THEN the system SHALL automatically convert and display all weight values in the new unit
4. WHEN the user enters weight THEN the system SHALL save it in the database in a unit-agnostic format and convert for display

### Requirement 6: Integration with Existing Weight Tracking

**User Story:** As a user, I want the new Weight section to work seamlessly with existing weight tracking features, so that all my weight data is consistent across the app.

#### Acceptance Criteria

1. WHEN the user logs weight through the new Weight section THEN the system SHALL use the same data storage as existing weight check-in features
2. WHEN the user logs weight through existing weight check-in features THEN the system SHALL display it in the new Weight section
3. WHEN the user views weight trends or charts THEN the system SHALL include weight data from both the new section and existing features
4. WHEN the user logs weight THEN the system SHALL update BMI calculations if applicable
