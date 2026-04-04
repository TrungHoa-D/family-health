import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:family_health/domain/entities/user_entity.dart';

part 'settings_state.freezed.dart';

class MedicalRecord {
  final String bloodType;
  final int heightCm;
  final int weightKg;

  const MedicalRecord({
    required this.bloodType,
    required this.heightCm,
    required this.weightKg,
  });
}

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
    MedicalRecord? medicalRecord,
    @Default([]) List<DailyRoutine> routines,
    @Default(false) bool isLoggingOut,
    @Default(false) bool isLoggedOut,
    @Default(false) bool isUpdatingProfile,
  }) = _SettingsState;
}
