part of 'category_list_cubit.dart';

@freezed
class CategoryListState with _$CategoryListState implements BaseCubitState {
  const factory CategoryListState({
    @Default(PageStatus.Uninitialized) PageStatus pageStatus,
    String? pageErrorMessage,
    @Default([]) List<MedicationCategory> categories,
    @Default({}) Map<String, int> medicationCountMap,
    @Default('') String searchQuery,
  }) = _CategoryListState;

  const CategoryListState._();

  List<MedicationCategory> get filteredCategories {
    if (searchQuery.isEmpty) return categories;
    final query = searchQuery.toLowerCase();
    return categories
        .where((c) =>
            c.name.toLowerCase().contains(query) ||
            (c.description?.toLowerCase().contains(query) ?? false))
        .toList();
  }

  int getMedCount(String categoryName) {
    return medicationCountMap[categoryName] ?? 0;
  }

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
