import 'package:freezed_annotation/freezed_annotation.dart';

part 'medication_log.freezed.dart';
part 'medication_log.g.dart';

@freezed
class MedicationLog with _$MedicationLog {
  const factory MedicationLog({
    @JsonKey(name: 'log_id') required String logId,
    @JsonKey(name: 'family_id') required String familyId,
    @JsonKey(name: 'schedule_id') required String scheduleId,
    @JsonKey(name: 'scheduled_time') required DateTime scheduledTime,
    required String status, // TAKEN, SKIPPED, MISSED
    @JsonKey(name: 'taken_time') DateTime? takenTime,
  }) = _MedicationLog;

  factory MedicationLog.fromJson(Map<String, dynamic> json) =>
      _$MedicationLogFromJson(json);
}
