part of 'dashboard_cubit.dart';


@freezed
class DashboardState with _$DashboardState implements BaseCubitState {
  const factory DashboardState({
    @Default(PageStatus.Uninitialized) PageStatus pageStatus,
    String? pageErrorMessage,
    UserEntity? user,
    @Default(0.0) double progress,
    @Default(0) int takenCount,
    @Default(0) int totalCount,
    @Default(0) int waitingCount,
    @Default(0) int missedCount,
    @Default([]) List<MedicationAlert> alerts,
    @Default([]) List<MemberStats> memberStats,
    @Default([]) List<MedicalEvent> ongoingEvents,
    @Default([]) List<MedicalEvent> upcomingEvents,
    @Default([]) List<MedicalEvent> incompleteEvents,
    @Default([]) List<MedicalEvent> completedEvents,
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
