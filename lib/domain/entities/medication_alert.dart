import 'package:freezed_annotation/freezed_annotation.dart';

part 'medication_alert.freezed.dart';

@freezed
class MedicationAlert with _$MedicationAlert {
  const factory MedicationAlert({
    required String scheduleId,
    required String userName,
    required String medName,
    required String dosage,
    required DateTime scheduledTime,
    required int delayMinutes,
  }) = _MedicationAlert;
}
