import 'package:family_health/domain/entities/medical_event.dart';
import 'package:family_health/domain/entities/user_entity.dart';
import 'package:family_health/domain/usecases/fetch_family_usecase.dart';
import 'package:family_health/domain/usecases/get_family_members_usecase.dart';
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
    this._notificationService,
    this._fetchFamilyUseCase,
    this._getFamilyMembersUseCase, {
    FirebaseAuth? firebaseAuth,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        super(AddEventState(
          startTime: DateTime.now(),
          endTime: DateTime.now().add(const Duration(hours: 1)),
        ));

  final SaveMedicalEventUseCase _saveMedicalEventUseCase;
  final GetUserUseCase _getUserUseCase;
  final NotificationService _notificationService;
  final FetchFamilyUseCase _fetchFamilyUseCase;
  final GetFamilyMembersUseCase _getFamilyMembersUseCase;
  final FirebaseAuth _firebaseAuth;

  Future<void> init({MedicalEvent? event}) async {
    emit(state.copyWith(pageStatus: PageStatus.Loading));
    
    try {
      final user = _firebaseAuth.currentUser;
      if (user != null) {
        final userEntity = await _getUserUseCase.call(params: user.uid);
        final familyId = userEntity?.familyId;
        if (familyId != null) {
          final family = await _fetchFamilyUseCase.call(params: familyId);
          if (family != null) {
            final members = await _getFamilyMembersUseCase.call(params: family.memberIds);
            emit(state.copyWith(familyMembers: members));
          }
        }
      }
    } catch (e) {
      // Ignore load members failure
    }
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
        selectedParticipantIds: event.participantIds,
        creatorId: event.creatorId,
        status: event.status,
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

  void toggleParticipant(String uid) {
    final current = List<String>.from(state.selectedParticipantIds);
    if (current.contains(uid)) {
      current.remove(uid);
    } else {
      current.add(uid);
    }
    emit(state.copyWith(selectedParticipantIds: current));
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

    emit(state.copyWith(isSaving: true, saveError: null));

    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) throw Exception('User not logged in');

      final userEntity = await _getUserUseCase.call(params: user.uid);
      final familyId = userEntity?.familyId;
      if (familyId == null) throw Exception('Family not found');

      final eventToSave = MedicalEvent(
        id: state.isEditing ? state.eventId : const Uuid().v4(),
        familyId: familyId,
        title: state.title,
        description: state.description,
        eventType: state.eventType.name.toUpperCase(),
        startTime: state.startTime,
        endTime: state.endTime,
        location: state.location,
        creatorId: state.isEditing ? state.creatorId : user.uid,
        participantIds: state.selectedParticipantIds,
        status: state.isEditing ? state.status : 'UPCOMING',
      );

      await _saveMedicalEventUseCase.call(params: eventToSave);

      // Schedule notification
      if (state.isEditing) {
        await _notificationService.cancelNotification(eventToSave.id.hashCode);
      }
      await _notificationService.scheduleEventReminder(eventToSave);

      emit(state.copyWith(isSaving: false, isSaved: true));
    } catch (e) {
      emit(state.copyWith(
        isSaving: false,
        saveError: e.toString(),
      ));
    }
  }
}
