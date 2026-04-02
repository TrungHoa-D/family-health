part of 'medication_detail_cubit.dart';

@freezed
class MedicationDetailState with _$MedicationDetailState
    implements BaseCubitState {
  const factory MedicationDetailState({
    @Default(PageStatus.Uninitialized) PageStatus pageStatus,
    String? pageErrorMessage,
    MedicationModel? medication,
  }) = _MedicationDetailState;

  const MedicationDetailState._();

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
