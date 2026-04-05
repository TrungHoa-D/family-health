import 'package:family_health/domain/entities/medical_event.dart';
import 'package:family_health/presentation/base/page_status.dart';
import 'package:family_health/presentation/cubit_base/base_cubit_state.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'events_state.freezed.dart';

@freezed
class EventsState with _$EventsState implements BaseCubitState {
  const factory EventsState({
    @Default(PageStatus.Uninitialized) PageStatus pageStatus,
    String? pageErrorMessage,
    required DateTime currentDate,
    required DateTime selectedDate,
    @Default([]) List<MedicalEvent> allEvents,
  }) = _EventsState;

  const EventsState._();

  @override
  BaseCubitState copyWithState({
    PageStatus? pageStatus,
    String? pageErrorMessage,
  }) {
    return copyWith(
      pageStatus: pageStatus ?? this.pageStatus,
      pageErrorMessage: pageErrorMessage ?? this.pageErrorMessage,
    );
  }

  /// Returns events for the selected date
  List<MedicalEvent> get selectedDateEvents {
    return allEvents.where((event) {
      return event.startTime.year == selectedDate.year &&
          event.startTime.month == selectedDate.month &&
          event.startTime.day == selectedDate.day;
    }).toList();
  }

  /// Returns the next 3 events occurring after the selected date
  List<MedicalEvent> get upcomingEvents {
    final endOfSelectedDate = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      23,
      59,
      59,
    );

    final upcoming = allEvents
        .where((event) => event.startTime.isAfter(endOfSelectedDate))
        .toList();
    upcoming.sort((a, b) => a.startTime.compareTo(b.startTime));

    return upcoming.take(3).toList();
  }
}
