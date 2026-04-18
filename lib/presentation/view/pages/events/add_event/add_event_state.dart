part of 'add_event_cubit.dart';

@freezed
class AddEventState with _$AddEventState implements BaseCubitState {
  const factory AddEventState({
    @Default(PageStatus.Uninitialized) PageStatus pageStatus,
    String? pageErrorMessage,
    @Default(false) bool isEditing,
    @Default('') String eventId,
    @Default('') String title,
    @Default('') String description,
    @Default('') String location,
    @Default(EventType.OTHER) EventType eventType,
    required DateTime startTime,
    required DateTime endTime,
    @Default([]) List<UserEntity> familyMembers,
    @Default([]) List<String> selectedParticipantIds,
    String? creatorId,
    @Default('UPCOMING') String status,
    @Default(false) bool finished,
    // --- Time mode ---
    /// Chế độ thời gian: 'from_to' | 'all_day' | 'meal_based'
    @Default('from_to') String timeMode,
    /// Bữa ăn nếu timeMode = 'meal_based'
    String? mealTime,
    // --- Validation errors ---
    String? titleError,
    String? participantError,
    // --- Medications ---
    @Default([]) List<Medication> availableMedications,
    Medication? selectedMedication,
    @Default(false) bool isLoadingMedications,
    // --- Save state ---
    @Default(false) bool isSaving,
    @Default(false) bool isSaved,
    String? saveError,
    String? imageUrl,
    String? medicationId,
  }) = _AddEventState;

  const AddEventState._();

  @override
  BaseCubitState copyWithState({
    PageStatus? pageStatus,
    String? pageErrorMessage,
  }) {
    return copyWith(
      pageStatus: pageStatus ?? this.pageStatus,
      pageErrorMessage: pageErrorMessage,
    );
  }
}
