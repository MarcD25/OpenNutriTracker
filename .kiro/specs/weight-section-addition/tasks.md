# Implementation Plan

- [ ] 1. Create Weight Input Dialog


  - Create `lib/core/presentation/widgets/weight_input_dialog.dart`
  - Implement text input field with numeric keyboard
  - Add unit label display (kg/lbs based on settings)
  - Implement real-time validation feedback
  - Add Save and Cancel buttons
  - Add Delete button for existing weight entries
  - _Requirements: 1.4, 2.4, 3.1, 3.2, 3.3, 3.4, 4.4, 5.1, 5.2_

- [ ] 2. Create Weight Section Widget for Home Page
  - Create `lib/features/home/presentation/widgets/weight_section_widget.dart`
  - Display "Add Weight (Optional)" when no weight logged
  - Display weight value with unit when logged
  - Make widget tappable to open weight input dialog
  - Style consistently with other meal sections (Activity, Breakfast, etc.)
  - Add scale icon for visual consistency
  - _Requirements: 1.1, 1.2, 1.3, 4.1, 5.1, 5.2_

- [ ] 3. Integrate Weight Section into Home Page
  - Modify `lib/features/home/home_page.dart`
  - Add Weight section after Snacks section
  - Pass today's weight data from HomeBloc state
  - Handle weight input dialog callbacks
  - Trigger HomeBloc refresh after weight save
  - Ensure proper ordering: Activity → Breakfast → Lunch → Dinner → Snacks → Weight
  - _Requirements: 1.1, 1.4, 1.5, 1.6, 6.1, 6.2, 6.4_

- [ ] 4. Create Weight Section Widget for Diary Page
  - Create `lib/features/diary/presentation/widgets/weight_section_widget.dart` (or reuse Home version)
  - Display "Add Weight (Optional)" when no weight logged for selected date
  - Display weight value with unit when logged for selected date
  - Make widget tappable to open weight input dialog
  - Pass selected date to weight input dialog
  - _Requirements: 2.1, 2.2, 2.3, 4.1, 5.1, 5.2_

- [ ] 5. Integrate Weight Section into Diary Page
  - Modify `lib/features/diary/diary_page.dart`
  - Add Weight section after Snacks section in day view
  - Pass selected date's weight data from DiaryBloc/CalendarDayBloc state
  - Handle weight input dialog callbacks
  - Trigger DiaryBloc refresh after weight save
  - Ensure proper ordering: Activity → Breakfast → Lunch → Dinner → Snacks → Weight
  - _Requirements: 2.1, 2.4, 2.5, 2.6, 6.1, 6.2, 6.4_

- [ ] 6. Wire up Weight Save Functionality
  - Use existing `WeightCheckinUsecase` to save weight
  - Use existing `WeightValidationService` for input validation
  - Save weight to database via existing data source
  - Update TrackedDayEntity with new weight value
  - Trigger BMI recalculation if applicable
  - Show success snackbar after save
  - _Requirements: 1.5, 1.6, 2.5, 2.6, 3.1, 3.2, 3.3, 5.4, 6.1, 6.2, 6.3, 6.4_

- [ ] 7. Add Localization Strings
  - Add "Add Weight (Optional)" string to l10n files
  - Add "Weight" section title string
  - Add validation error messages
  - Add success/failure messages
  - Support both English and German
  - _Requirements: 3.3, 4.1_

- [ ] 8. Manual Testing and Verification
  - Test adding weight on Home page for today
  - Test editing weight on Home page
  - Test adding weight on Diary page for selected date
  - Test editing weight on Diary page for past dates
  - Test deleting weight entries
  - Test unit conversion (kg ↔ lbs)
  - Test validation (min/max values, invalid input)
  - Test integration with existing weight check-in features
  - Verify BMI updates after weight change
  - Test on different screen sizes
  - _Requirements: All requirements_
