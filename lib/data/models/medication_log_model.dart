import 'package:family_health/domain/entities/medication_log.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'medication_log_model.freezed.dart';
part 'medication_log_model.g.dart';

@freezed
class MedicationLogModel with _$MedicationLogModel {
  const factory MedicationLogModel({
    @JsonKey(name: 'log_id') required String logId,
    @JsonKey(name: 'family_id') required String familyId,
    @JsonKey(name: 'schedule_id') required String scheduleId,
    @JsonKey(name: 'scheduled_time') required DateTime scheduledTime,
    required String status,
    @JsonKey(name: 'taken_time') DateTime? takenTime,
  }) = _MedicationLogModel;

  const MedicationLogModel._();

  factory MedicationLogModel.fromJson(Map<String, dynamic> json) =>
      _$MedicationLogModelFromJson(json);

  factory MedicationLogModel.fromEntity(MedicationLog entity) {
    return MedicationLogModel(
      logId: entity.logId,
      familyId: entity.familyId,
      scheduleId: entity.scheduleId,
      scheduledTime: entity.scheduledTime,
      status: entity.status,
      takenTime: entity.takenTime,
    );
  }

  MedicationLog toEntity() {
    return MedicationLog(
      logId: logId,
      familyId: familyId,
      scheduleId: scheduleId,
      scheduledTime: scheduledTime,
      status: status,
      takenTime: takenTime,
    );
  }
}
