part of 'edit_routines_cubit.dart';

@freezed
class EditRoutinesState with _$EditRoutinesState implements BaseCubitState {
  const factory EditRoutinesState({
    @Default(PageStatus.Uninitialized) PageStatus pageStatus,
    String? pageErrorMessage,
    @Default([]) List<DailyRoutine> routines,
    @Default(false) bool isSaving,
    @Default(false) bool isSaved,
    String? saveError,
  }) = _EditRoutinesState;

  const EditRoutinesState._();

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
