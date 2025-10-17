# Design Document

## Overview

This design adds a Weight section to both the Home and Diary pages, positioned after the Snacks section. The implementation will reuse existing weight check-in infrastructure while providing a more accessible interface for daily weight logging.

## Architecture

### Component Structure

```
Home Page / Diary Page
├── Activity Section
├── Breakfast Section
├── Lunch Section
├── Dinner Section
├── Snacks Section
└── Weight Section (NEW)
    ├── Weight Display Widget
    ├── Weight Input Dialog
    └── Weight Validation Service
```

### Data Flow

1. User taps Weight section → Opens weight input dialog
2. User enters weight → Validation service checks input
3. Valid input → Save to database via existing WeightCheckinUsecase
4. Database updated → Bloc emits new state
5. UI updates → Display new weight value

## Components and Interfaces

### 1. Weight Section Widget

**Location:** `lib/features/home/presentation/widgets/weight_section_widget.dart` and `lib/features/diary/presentation/widgets/weight_section_widget.dart`

**Purpose:** Display weight section with current weight or prompt to add weight

**Interface:**
```dart
class WeightSectionWidget extends StatelessWidget {
  final DateTime date;
  final double? currentWeight;
  final bool usesImperialUnits;
  final VoidCallback onTap;
  
  const WeightSectionWidget({
    required this.date,
    this.currentWeight,
    required this.usesImperialUnits,
    required this.onTap,
  });
}
```

**Behavior:**
- Shows "Add Weight (Optional)" if no weight logged
- Shows weight value with unit if logged
- Tappable to open weight input dialog
- Styled consistently with other meal sections

### 2. Weight Input Dialog

**Location:** `lib/core/presentation/widgets/weight_input_dialog.dart`

**Purpose:** Allow user to input or edit weight for a specific date

**Interface:**
```dart
class WeightInputDialog extends StatefulWidget {
  final DateTime date;
  final double? initialWeight;
  final bool usesImperialUnits;
  
  const WeightInputDialog({
    required this.date,
    this.initialWeight,
    required this.usesImperialUnits,
  });
}
```

**Features:**
- Text input field for weight
- Unit label (kg or lbs)
- Save and Cancel buttons
- Real-time validation feedback
- Option to delete existing weight entry

### 3. Integration Points

#### Home Page Integration

**File:** `lib/features/home/home_page.dart`

**Changes:**
- Add Weight section after Snacks section
- Pass current date's weight data to widget
- Handle weight update callbacks
- Refresh home page data after weight save

#### Diary Page Integration

**File:** `lib/features/diary/diary_page.dart`

**Changes:**
- Add Weight section after Snacks section in day view
- Pass selected date's weight data to widget
- Handle weight update callbacks
- Refresh diary data after weight save

#### Existing Weight Check-in Integration

**Files:** 
- `lib/features/weight_checkin/domain/usecase/weight_checkin_usecase.dart`
- `lib/features/weight_checkin/data/data_source/weight_checkin_data_source.dart`

**Usage:**
- Reuse existing `WeightCheckinUsecase` for saving weight
- Reuse existing data source for retrieving weight
- Ensure data consistency across all weight tracking features

## Data Models

### Weight Entry

The existing `TrackedDayEntity` already contains weight data:

```dart
class TrackedDayEntity {
  final DateTime day;
  final double? weight;  // Already exists
  // ... other fields
}
```

No new data models needed - we'll use the existing weight field in `TrackedDayEntity`.

## Error Handling

### Validation Errors

1. **Invalid Input Format**
   - Error: "Please enter a valid number"
   - Action: Show error message, keep dialog open

2. **Out of Range**
   - Error: "Weight must be between 20-500 kg (44-1100 lbs)"
   - Action: Show error message, keep dialog open

3. **Empty Input**
   - Error: "Please enter your weight"
   - Action: Show error message, keep dialog open

### Database Errors

1. **Save Failure**
   - Error: "Failed to save weight. Please try again."
   - Action: Show snackbar, keep dialog open

2. **Load Failure**
   - Error: Silent failure, show "Add Weight" prompt
   - Action: Log error, allow user to add weight

## Testing Strategy

### Unit Tests

1. **Weight Validation Service**
   - Test valid weight values
   - Test invalid weight values (negative, zero, out of range)
   - Test decimal precision handling
   - Test unit conversion

2. **Weight Section Widget**
   - Test display with no weight
   - Test display with weight value
   - Test unit display (kg vs lbs)
   - Test tap callback

### Widget Tests

1. **Weight Input Dialog**
   - Test initial state with no weight
   - Test initial state with existing weight
   - Test input validation feedback
   - Test save button enabled/disabled states
   - Test cancel button
   - Test delete button (when weight exists)

### Integration Tests

1. **Home Page Weight Section**
   - Test adding weight for today
   - Test editing existing weight
   - Test weight display after save
   - Test unit conversion

2. **Diary Page Weight Section**
   - Test adding weight for selected date
   - Test editing weight for past date
   - Test weight display for different dates
   - Test navigation between dates

3. **Cross-Feature Integration**
   - Test weight added via new section appears in weight check-in screen
   - Test weight added via weight check-in appears in new section
   - Test BMI updates after weight change

## UI/UX Considerations

### Visual Design

- Weight section should match the style of meal sections (Activity, Breakfast, etc.)
- Use scale icon to represent weight
- Show unit (kg/lbs) clearly
- Use subtle styling to indicate optional nature

### User Experience

- Single tap to add/edit weight (no long press needed)
- Quick input with numeric keyboard
- Immediate feedback on save
- No confirmation dialog for delete (use undo snackbar instead)
- Smooth animations for state changes

### Accessibility

- Proper labels for screen readers
- Sufficient touch target size (minimum 48x48dp)
- Clear error messages
- Keyboard navigation support

## Implementation Notes

### Reusing Existing Code

The app already has comprehensive weight tracking infrastructure:
- `WeightCheckinUsecase` for business logic
- `WeightCheckinDataSource` for data persistence
- `WeightValidationService` for input validation
- `TrackedDayEntity` with weight field

We'll reuse all of these components to ensure consistency and avoid duplication.

### State Management

- Home page: Use existing `HomeBloc` to manage weight state
- Diary page: Use existing `DiaryBloc` and `CalendarDayBloc` to manage weight state
- Weight updates trigger bloc events to refresh UI

### Performance

- Weight data already loaded with tracked day data (no additional queries)
- Input dialog is lightweight (no heavy computations)
- Validation happens synchronously (no network calls)

## Migration Considerations

- No database migration needed (weight field already exists)
- No breaking changes to existing features
- Backward compatible with existing weight data
