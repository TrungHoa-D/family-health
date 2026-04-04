import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:family_health/domain/entities/user_entity.dart';
import 'package:family_health/domain/entities/health_profile.dart';

part 'settings_state.freezed.dart';

class DailyRoutine {
  final String title;
  final String subtitle;
  final String time;

  const DailyRoutine({
    required this.title,
    required this.subtitle,
    required this.time,
  });
}

@freezed
class SettingsState with _$SettingsState {
  const factory SettingsState({
    UserEntity? user,
    @Default('V I T A L I S - 8 8') String inviteCode,
    HealthProfile? medicalRecord,
    @Default([]) List<DailyRoutine> routines,
    @Default(false) bool isLoggingOut,
    @Default(false) bool isLoggedOut,
    @Default(false) bool isUpdatingProfile,
  }) = _SettingsState;
}
