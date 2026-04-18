import 'package:easy_localization/easy_localization.dart';
import 'package:family_health/domain/entities/medical_event.dart';
import 'package:family_health/domain/entities/medication.dart';
import 'package:family_health/domain/entities/user_entity.dart';
import 'package:family_health/domain/usecases/fetch_family_usecase.dart';
import 'package:family_health/domain/usecases/get_family_members_usecase.dart';
import 'package:family_health/domain/usecases/get_user_usecase.dart';
import 'package:family_health/domain/usecases/save_medical_event_usecase.dart';
import 'package:family_health/domain/usecases/watch_medications_usecase.dart';
import 'package:family_health/presentation/base/page_status.dart';
import 'package:family_health/presentation/cubit_base/base_cubit.dart';
import 'package:family_health/presentation/cubit_base/base_cubit_state.dart';
import 'package:family_health/shared/services/notification_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';
import 'dart:async';

part 'add_event_cubit.freezed.dart';
part 'add_event_state.dart';

/// Giờ mặc định cho mỗi bữa ăn (Option B: cố định, không phụ thuộc anchor_times)
const _mealStartHours = {
  'breakfast': 7,
  'lunch': 12,
  'dinner': 18,
  'snack': 15,
};
const _mealDurationHours = 1;

@injectable
class AddEventCubit extends BaseCubit<AddEventState> {
  AddEventCubit(
    this._saveMedicalEventUseCase,
    this._getUserUseCase,
    this._notificationService,
    this._fetchFamilyUseCase,
    this._getFamilyMembersUseCase,
    this._watchMedicationsUseCase, {
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
  final WatchMedicationsUseCase _watchMedicationsUseCase;
  final FirebaseAuth _firebaseAuth;
  StreamSubscription? _medsSubscription;

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
            final members =
                await _getFamilyMembersUseCase.call(params: family.memberIds);
            emit(state.copyWith(familyMembers: members));
            _loadMedications(familyId);
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
        finished: event.finished,
        timeMode: event.timeMode,
        mealTime: event.mealTime,
        imageUrl: event.imageUrl,
        medicationId: event.medicationId,
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

  // ─── Time Mode ──────────────────────────────────────────────────────────────

  void updateTimeMode(String mode) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    DateTime newStart;
    DateTime newEnd;

    switch (mode) {
      case 'all_day':
        // Cả ngày: 00:00 — 23:59 hôm nay
        newStart = today;
        newEnd = today.add(const Duration(hours: 23, minutes: 59));
        break;
      case 'meal_based':
        // Mặc định theo bữa sáng
        final mealTime = state.mealTime ?? 'breakfast';
        newStart = _buildMealTime(today, mealTime);
        newEnd = newStart.add(const Duration(hours: _mealDurationHours));
        break;
      case 'from_to':
      default:
        newStart = state.startTime;
        newEnd = state.endTime;
        break;
    }

    emit(state.copyWith(
      timeMode: mode,
      startTime: newStart,
      endTime: newEnd,
    ));
  }

  void updateMealTime(String mealTime) {
    final today = DateTime(
      state.startTime.year,
      state.startTime.month,
      state.startTime.day,
    );
    final newStart = _buildMealTime(today, mealTime);
    final newEnd = newStart.add(const Duration(hours: _mealDurationHours));
    emit(state.copyWith(
      mealTime: mealTime,
      startTime: newStart,
      endTime: newEnd,
    ));
  }

  void updateAllDayDate(DateTime date) {
    final today = DateTime(date.year, date.month, date.day);
    emit(state.copyWith(
      startTime: today,
      endTime: today.add(const Duration(hours: 23, minutes: 59)),
    ));
  }

  void updateMealDate(DateTime date) {
    final today = DateTime(date.year, date.month, date.day);
    final mealTime = state.mealTime ?? 'breakfast';
    final newStart = _buildMealTime(today, mealTime);
    emit(state.copyWith(
      startTime: newStart,
      endTime: newStart.add(const Duration(hours: _mealDurationHours)),
    ));
  }

  DateTime _buildMealTime(DateTime date, String mealTime) {
    final hour = _mealStartHours[mealTime] ?? 7;
    return DateTime(date.year, date.month, date.day, hour, 0);
  }

  // ─── Standard Time Pickers ───────────────────────────────────────────────────

  void updateStartTime(DateTime time) {
    emit(state.copyWith(startTime: time));
    if (state.endTime.isBefore(time)) {
      emit(state.copyWith(endTime: time.add(const Duration(hours: 1))));
    }
  }

  void updateEndTime(DateTime time) {
    emit(state.copyWith(endTime: time));
  }

  // ─── Participants ────────────────────────────────────────────────────────────

  void toggleParticipant(String uid) {
    final current = List<String>.from(state.selectedParticipantIds);
    if (current.contains(uid)) {
      current.remove(uid);
    } else {
      current.add(uid);
    }
    emit(state.copyWith(
      selectedParticipantIds: current,
      participantError: null,
    ));
  }

  // ─── Medications ─────────────────────────────────────────────────────────────

  void _loadMedications(String familyId) {
    _medsSubscription?.cancel();
    emit(state.copyWith(isLoadingMedications: true));
    _medsSubscription = _watchMedicationsUseCase.call(familyId).listen((meds) {
      emit(state.copyWith(
        availableMedications: meds,
        isLoadingMedications: false,
      ));

      // If editing and has medicationId, try to find the selected medication
      if (state.medicationId != null && state.selectedMedication == null) {
        final med = meds.where((m) => m.id == state.medicationId).firstOrNull;
        if (med != null) {
          emit(state.copyWith(selectedMedication: med));
        }
      }
    });
  }

  void selectMedication(Medication? med) {
    emit(state.copyWith(
      selectedMedication: med,
      medicationId: med?.id,
      imageUrl: med?.imageUrl,
    ));
  }

  // ─── Validate & Save ─────────────────────────────────────────────────────────

  bool validate() {
    String? titleError;
    String? participantError;

    if (state.title.trim().isEmpty) {
      titleError = 'events.validation.title_required'.tr();
    }

    if (state.selectedParticipantIds.isEmpty) {
      participantError = 'events.validation.participant_required'.tr();
    }

    if (titleError != null || participantError != null) {
      emit(state.copyWith(
        titleError: titleError,
        participantError: participantError,
      ));
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
        finished: state.isEditing ? state.finished : false,
        timeMode: state.timeMode,
        mealTime: state.mealTime,
        medicationId: state.medicationId,
        imageUrl: state.imageUrl,
      );

      await _saveMedicalEventUseCase.call(params: eventToSave);

      // Notifications for events will now be handled globally by AutoSchedulerService

      emit(state.copyWith(isSaving: false, isSaved: true));
    } catch (e) {
      emit(state.copyWith(
        isSaving: false,
        saveError: e.toString(),
      ));
    }
  }

  @override
  Future<void> close() {
    _medsSubscription?.cancel();
    return super.close();
  }
}
