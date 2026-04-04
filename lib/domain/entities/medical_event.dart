import 'package:freezed_annotation/freezed_annotation.dart';

part 'medical_event.freezed.dart';
part 'medical_event.g.dart';

enum EventType {
  VACCINE,
  CHECKUP,
  DENTAL,
  OTHER,
}

@freezed
class MedicalEvent with _$MedicalEvent {
  const factory MedicalEvent({
    required String id,
    required EventType type,
    required String title,
    required String targetUserId,
    required DateTime date,
    required String location,
    String? note,
    @Default([]) List<String> attendeeIds,
    @Default(true) bool isNotificationEnabled,
  }) = _MedicalEvent;

  factory MedicalEvent.fromJson(Map<String, dynamic> json) =>
      _$MedicalEventFromJson(json);
}
