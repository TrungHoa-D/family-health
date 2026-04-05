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
    @JsonKey(name: 'family_id') required String familyId,
    required String title,
    String? description,
    @JsonKey(name: 'event_type') required String eventType, // VACCINE, CHECKUP, etc.
    @JsonKey(name: 'start_time') required DateTime startTime,
    @JsonKey(name: 'end_time') required DateTime endTime,
    required String location,
  }) = _MedicalEvent;

  factory MedicalEvent.fromJson(Map<String, dynamic> json) =>
      _$MedicalEventFromJson(json);
}
