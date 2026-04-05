import 'package:family_health/domain/entities/health_profile.dart';
import 'package:family_health/domain/entities/user_entity.dart';
import 'package:family_health/presentation/base/page_status.dart';
import 'package:family_health/presentation/cubit_base/base_cubit_state.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'settings_state.freezed.dart';

class DailyRoutine {
  const DailyRoutine({
    required this.title,
    required this.subtitle,
    required this.time,
  });
  final String title;
  final String subtitle;
  final String time;
}

@freezed
class SettingsState with _$SettingsState implements BaseCubitState {
  const factory SettingsState({
    @Default(PageStatus.Uninitialized) PageStatus pageStatus,
    String? pageErrorMessage,
    UserEntity? user,
    @Default('V I T A L I S - 8 8') String inviteCode,
    HealthProfile? medicalRecord,
    @Default([]) List<DailyRoutine> routines,
    @Default(false) bool isLoggingOut,
    @Default(false) bool isLoggedOut,
    @Default(false) bool isUpdatingProfile,
  }) = _SettingsState;

  const SettingsState._();

  @override
  BaseCubitState copyWithState({
    PageStatus? pageStatus,
    String? pageErrorMessage,
  }) {
    return copyWith(
      pageStatus: pageStatus ?? this.pageStatus,
      pageErrorMessage: pageErrorMessage ?? this.pageErrorMessage,
    );
  }
}
