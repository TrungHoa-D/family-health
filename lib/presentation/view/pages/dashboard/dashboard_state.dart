part of 'dashboard_cubit.dart';

@freezed
class DashboardState with _$DashboardState implements BaseCubitState {
  const factory DashboardState({
    @Default(PageStatus.Uninitialized) PageStatus pageStatus,
    String? pageErrorMessage,
    UserEntity? user,
    @Default(0.67) double progress,
    @Default(4) int takenCount,
    @Default(6) int totalCount,
    @Default(1) int waitingCount,
    @Default(1) int missedCount,
    @Default([]) List<MedicationAlert> alerts,
  }) = _DashboardState;

  const DashboardState._();

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
