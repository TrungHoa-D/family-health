part of 'category_meds_cubit.dart';

@freezed
class CategoryMedsState with _$CategoryMedsState implements BaseCubitState {
  const factory CategoryMedsState({
    @Default(PageStatus.Uninitialized) PageStatus pageStatus,
    String? pageErrorMessage,
    @Default('') String categoryName,
    @Default([]) List<MedicationModel> medications,
  }) = _CategoryMedsState;

  const CategoryMedsState._();

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
