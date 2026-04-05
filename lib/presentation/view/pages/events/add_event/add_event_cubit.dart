import 'package:family_health/domain/entities/medical_event.dart';
import 'package:family_health/domain/usecases/get_user_usecase.dart';
import 'package:family_health/domain/usecases/save_medical_event_usecase.dart';
import 'package:family_health/presentation/base/page_status.dart';
import 'package:family_health/presentation/cubit_base/base_cubit.dart';
import 'package:family_health/presentation/cubit_base/base_cubit_state.dart';
import 'package:family_health/shared/services/notification_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';

part 'add_event_cubit.freezed.dart';
part 'add_event_state.dart';

@injectable
class AddEventCubit extends BaseCubit<AddEventState> {
  AddEventCubit(
    this._saveMedicalEventUseCase,
    this._getUserUseCase,
    this._notificationService, {
    FirebaseAuth? firebaseAuth,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        super(AddEventState(
          startTime: DateTime.now(),
          endTime: DateTime.now().add(const Duration(hours: 1)),
        ));

  final SaveMedicalEventUseCase _saveMedicalEventUseCase;
  final GetUserUseCase _getUserUseCase;
  final NotificationService _notificationService;
  final FirebaseAuth _firebaseAuth;

  void init({MedicalEvent? event}) {
    if (event != null) {
      emit(state.copyWith(
        pageStatus: PageStatus.Loaded,
        isEditing: true,
        eventId: event.id,
        title: event.title,
        description: event.description ?? '',
        eventType: _getEnumFromType(event.eventType),
        startTime: event.startTime,
        endTime: event.endTime,
        location: event.location,
      ));
    } else {
      final now = DateTime.now();
      emit(state.copyWith(
        pageStatus: PageStatus.Loaded,
        startTime: now,
        endTime: now.add(const Duration(hours: 1)),
      ));
    }
  }

  EventType _getEnumFromType(String type) {
    return EventType.values.firstWhere(
      (e) => e.name.toUpperCase() == type.toUpperCase(),
      orElse: () => EventType.OTHER,
    );
  }

  void updateTitle(String value) {
    emit(state.copyWith(title: value, titleError: null));
  }

  void updateDescription(String value) {
    emit(state.copyWith(description: value));
  }

  void updateLocation(String value) {
    emit(state.copyWith(location: value));
  }

  void updateType(EventType type) {
    emit(state.copyWith(eventType: type));
  }

  void updateStartTime(DateTime time) {
    emit(state.copyWith(startTime: time));
    if (state.endTime.isBefore(time)) {
      emit(state.copyWith(endTime: time.add(const Duration(hours: 1))));
    }
  }

  void updateEndTime(DateTime time) {
    emit(state.copyWith(endTime: time));
  }

  bool validate() {
    String? titleError;
    if (state.title.trim().isEmpty) {
      titleError = 'Vui lòng nhập tiêu đề sự kiện';
    }

    if (titleError != null) {
      emit(state.copyWith(titleError: titleError));
      return false;
    }
    return true;
  }

  Future<void> save() async {
    if (!validate()) return;

    await _notificationService.requestPermissions();

    emit(state.copyWith(pageStatus: PageStatus.Loading));

    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) throw Exception('User not logged in');

      final userEntity = await _getUserUseCase.call(params: user.uid);
      final familyId = userEntity?.familyId;
      if (familyId == null) throw Exception('Family not found');

      final event = MedicalEvent(
        id: state.isEditing ? state.eventId : const Uuid().v4(),
        familyId: familyId,
        title: state.title,
        description: state.description,
        eventType: state.eventType.name.toUpperCase(),
        startTime: state.startTime,
        endTime: state.endTime,
        location: state.location,
      );

      await _saveMedicalEventUseCase.call(params: event);

      // Schedule notification
      if (state.isEditing) {
        await _notificationService.cancelNotification(event.id.hashCode);
      }
      await _notificationService.scheduleEventReminder(event);

      emit(state.copyWith(pageStatus: PageStatus.Loaded, isSaved: true));
    } catch (e) {
      emit(state.copyWith(
        pageStatus: PageStatus.Error,
        pageErrorMessage: e.toString(),
      ));
    }
  }
}
