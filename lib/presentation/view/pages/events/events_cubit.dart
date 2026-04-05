import 'package:family_health/presentation/base/page_status.dart';
import 'package:family_health/presentation/cubit_base/base_cubit.dart';
import 'package:family_health/presentation/view/pages/events/events_state.dart';
import 'package:injectable/injectable.dart';

@injectable
class EventsCubit extends BaseCubit<EventsState> {
  EventsCubit()
      : super(
          EventsState(
            pageStatus: PageStatus.Loaded,
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
