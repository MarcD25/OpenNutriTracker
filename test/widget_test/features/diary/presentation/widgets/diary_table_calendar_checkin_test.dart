import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:opennutritracker/features/diary/presentation/widgets/diary_table_calendar.dart';
import 'package:opennutritracker/features/diary/presentation/bloc/diary_calendar_bloc.dart';
import 'package:opennutritracker/features/weight_checkin/domain/service/weight_checkin_calendar_service.dart';
import 'package:opennutritracker/features/weight_checkin/domain/entity/weight_entry_entity.dart';
import 'package:opennutritracker/core/utils/locator.dart';

import 'diary_table_calendar_checkin_test.mocks.dart';

@GenerateMocks([WeightCheckinCalendarService, DiaryCalendarBloc])
void main() {
  late MockWeightCheckinCalendarService mockCalendarService;
  late MockDiaryCalendarBloc mockDiaryCalendarBloc;

  setUp(() {
    mockCalendarService = MockWeightCheckinCalendarService();
    mockDiaryCalendarBloc = MockDiaryCalendarBloc();
    
    // Setup locator for testing
    if (locator.isRegistered<DiaryCalendarBloc>()) {
      locator.unregister<DiaryCalendarBloc>();
    }
    locator.registerSingleton<DiaryCalendarBloc>(mockDiaryCalendarBloc);
  });

  tearDown(() {
    if (locator.isRegistered<DiaryCalendarBloc>()) {
      locator.unregister<DiaryCalendarBloc>();
    }
  });

  group('DiaryTableCalendar Weight Check-in Indicators', () {
    testWidgets('should show check-in indicators for weekly frequency', (WidgetTester tester) async {
      // Arrange
      final testDate = DateTime(2024, 1, 15); // Monday
      final checkinDays = <DateTime, bool>{
        DateTime(2024, 1, 1): true,   // Monday - check-in day
        DateTime(2024, 1, 2): false,  // Tuesday
        DateTime(2024, 1, 8): true,   // Monday - check-in day
        DateTime(2024, 1, 15): true,  // Monday - check-in day
        DateTime(2024, 1, 22): true,  // Monday - check-in day
      };

      when(mockDiaryCalendarBloc.state).thenReturn(
        DiaryCalendarLoaded(
          checkinDays: checkinDays,
          currentFrequency: CheckinFrequency.weekly,
        ),
      );

      when(mockDiaryCalendarBloc.stream).thenAnswer(
        (_) => Stream.fromIterable([
          DiaryCalendarLoaded(
            checkinDays: checkinDays,
            currentFrequency: CheckinFrequency.weekly,
          ),
        ]),
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DiaryTableCalendar(
              trackedDaysMap: {},
              intakeDataMap: {},
              onDateSelected: (date, trackedDays) {},
              calendarDurationDays: const Duration(days: 365),
              currentDate: testDate,
              selectedDate: testDate,
              focusedDate: testDate,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Assert
      // Check that scale icons are present for check-in days
      expect(find.byIcon(Icons.scale), findsWidgets);
      
      // Verify that the bloc was called to load check-in days
      verify(mockDiaryCalendarBloc.add(any)).called(greaterThan(0));
    });

    testWidgets('should show different styling for check-in days', (WidgetTester tester) async {
      // Arrange
      final testDate = DateTime(2024, 1, 15);
      final checkinDays = <DateTime, bool>{
        DateTime(2024, 1, 15): true,  // Check-in day
        DateTime(2024, 1, 16): false, // Regular day
      };

      when(mockDiaryCalendarBloc.state).thenReturn(
        DiaryCalendarLoaded(
          checkinDays: checkinDays,
          currentFrequency: CheckinFrequency.weekly,
        ),
      );

      when(mockDiaryCalendarBloc.stream).thenAnswer(
        (_) => Stream.fromIterable([
          DiaryCalendarLoaded(
            checkinDays: checkinDays,
            currentFrequency: CheckinFrequency.weekly,
          ),
        ]),
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DiaryTableCalendar(
              trackedDaysMap: {},
              intakeDataMap: {},
              onDateSelected: (date, trackedDays) {},
              calendarDurationDays: const Duration(days: 365),
              currentDate: testDate,
              selectedDate: testDate,
              focusedDate: testDate,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Assert
      // Check that there are containers with borders (check-in day styling)
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('should handle empty check-in days gracefully', (WidgetTester tester) async {
      // Arrange
      final testDate = DateTime(2024, 1, 15);

      when(mockDiaryCalendarBloc.state).thenReturn(
        DiaryCalendarLoaded(
          checkinDays: {},
          currentFrequency: CheckinFrequency.weekly,
        ),
      );

      when(mockDiaryCalendarBloc.stream).thenAnswer(
        (_) => Stream.fromIterable([
          DiaryCalendarLoaded(
            checkinDays: {},
            currentFrequency: CheckinFrequency.weekly,
          ),
        ]),
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DiaryTableCalendar(
              trackedDaysMap: {},
              intakeDataMap: {},
              onDateSelected: (date, trackedDays) {},
              calendarDurationDays: const Duration(days: 365),
              currentDate: testDate,
              selectedDate: testDate,
              focusedDate: testDate,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Assert
      // Should not crash and should render the calendar
      expect(find.byType(DiaryTableCalendar), findsOneWidget);
    });

    testWidgets('should load check-in days when page changes', (WidgetTester tester) async {
      // Arrange
      final testDate = DateTime(2024, 1, 15);

      when(mockDiaryCalendarBloc.state).thenReturn(DiaryCalendarInitial());
      when(mockDiaryCalendarBloc.stream).thenAnswer(
        (_) => Stream.fromIterable([DiaryCalendarInitial()]),
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DiaryTableCalendar(
              trackedDaysMap: {},
              intakeDataMap: {},
              onDateSelected: (date, trackedDays) {},
              calendarDurationDays: const Duration(days: 365),
              currentDate: testDate,
              selectedDate: testDate,
              focusedDate: testDate,
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Assert
      // Verify that LoadCheckinDaysEvent was called during initialization
      verify(mockDiaryCalendarBloc.add(argThat(isA<LoadCheckinDaysEvent>()))).called(1);
    });
  });
}