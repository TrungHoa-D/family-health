import 'package:freezed_annotation/freezed_annotation.dart';
part 'events_state.freezed.dart';

enum EventType { vaccine, dentistry, checkup, other }

class EventModel {
  const EventModel({
    required this.id,
    required this.title,
    required this.time,
    required this.location,
    required this.type,
  });
  final String id;
  final String title;
  final DateTime time;
  final String location;
  final EventType type;
}

@freezed
class EventsState with _$EventsState {
  const factory EventsState({
    required DateTime currentDate,
    required DateTime selectedDate,
    required List<EventModel> allEvents,
  }) = _EventsState;

  const EventsState._();

  /// Returns events for the selected date
  List<EventModel> get selectedDateEvents {
    return allEvents.where((event) {
      return event.time.year == selectedDate.year &&
          event.time.month == selectedDate.month &&
          event.time.day == selectedDate.day;
    }).toList();
  }

  /// Returns the next 3 events occurring after the selected date
  List<EventModel> get upcomingEvents {
    final endOfSelectedDate = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      23,
      59,
      59,
    );

    final upcoming = allEvents
        .where((event) => event.time.isAfter(endOfSelectedDate))
        .toList();
    upcoming.sort((a, b) => a.time.compareTo(b.time));

    return upcoming.take(3).toList();
  }
}
