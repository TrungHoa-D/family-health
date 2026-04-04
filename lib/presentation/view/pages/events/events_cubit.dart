import 'package:family_health/presentation/view/pages/events/events_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EventsCubit extends Cubit<EventsState> {
  EventsCubit()
      : super(
          EventsState(
            currentDate: DateTime.now(),
            selectedDate: DateTime.now(),
            allEvents: _mockEvents(),
          ),
        );

  void selectDate(DateTime date) {
    emit(state.copyWith(selectedDate: date));
  }

  static List<EventModel> _mockEvents() {
    final now = DateTime.now();
    return [
      EventModel(
        id: '1',
        title: 'Tiêm chủng cúm mùa',
        time: DateTime(now.year, now.month, now.day, 9, 30),
        location: 'BV Hoàn Mỹ',
        type: EventType.vaccine,
      ),
      EventModel(
        id: '2',
        title: 'Lấy cao răng',
        time: DateTime(now.year, now.month, now.day + 2, 15, 0),
        location: 'Nha khoa Westway',
        type: EventType.dentistry,
      ),
      EventModel(
        id: '3',
        title: 'Khám sức khỏe tổng quát',
        time: DateTime(now.year, now.month, now.day + 5, 8, 0),
        location: 'BV FV',
        type: EventType.checkup,
      ),
      EventModel(
        id: '4',
        title: 'Tái khám huyết áp',
        time: DateTime(now.year, now.month, now.day - 1, 10, 0),
        location: 'Phòng khám ABC',
        type: EventType.checkup,
      ),
    ];
  }
}
