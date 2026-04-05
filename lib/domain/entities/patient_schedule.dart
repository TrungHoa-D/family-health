import 'package:freezed_annotation/freezed_annotation.dart';

part 'patient_schedule.freezed.dart';
part 'patient_schedule.g.dart';

@freezed
class PatientSchedule with _$PatientSchedule {
  const factory PatientSchedule({
    required String id,
    @JsonKey(name: 'med_id') required String medId,
    @JsonKey(name: 'med_name') required String medName,
    @JsonKey(name: 'family_id') required String familyId,
    @JsonKey(name: 'target_user_id') required String targetUserId,
    @JsonKey(name: 'created_by') required String createdBy,
    required String dosage,
    @JsonKey(name: 'notified_user_ids') @Default([]) List<String> notifiedUserIds,
    required Map<String, dynamic> timing, // e.g. {anchor_event: 'breakfast', offset: -30, type: 'offset'}
  }) = _PatientSchedule;

  factory PatientSchedule.fromJson(Map<String, dynamic> json) =>
      _$PatientScheduleFromJson(json);
}
