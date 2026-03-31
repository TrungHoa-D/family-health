part of 'home_cubit.dart';

@freezed
class HomeState with _$HomeState implements BaseCubitState {
  const factory HomeState({
    @Default(PageStatus.Uninitialized) PageStatus pageStatus,
    @Default(0) int currentTabIndex,
    String? pageErrorMessage,
    UserEntity? user,
  }) = _HomeState;

  const HomeState._();

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
