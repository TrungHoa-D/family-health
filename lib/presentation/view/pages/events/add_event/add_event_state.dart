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
    String? titleError,
    @Default(false) bool isSaved,
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
