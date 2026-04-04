import 'package:freezed_annotation/freezed_annotation.dart';

part 'patient_schedule.freezed.dart';
part 'patient_schedule.g.dart';

enum Frequency {
  DAILY,
  WEEKLY,
  MONTHLY,
  ONCE,
}

@freezed
class PatientSchedule with _$PatientSchedule {
  const factory PatientSchedule({
    required String id,
    required String medicationId,
    required String targetUserId,
    required String
        anchorTimeKey, // e.g., 'breakfast', 'lunch', 'dinner', 'sleep'
    @Default(0) int offsetMinutes, // e.g., -30 for before, 30 for after
    @Default([]) List<String> supervisorIds,
    @Default(Frequency.DAILY) Frequency frequency,
    @Default(true) bool isActive,
    DateTime? startDate,
    DateTime? endDate,
  }) = _PatientSchedule;

  factory PatientSchedule.fromJson(Map<String, dynamic> json) =>
      _$PatientScheduleFromJson(json);
}
