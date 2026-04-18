import 'package:freezed_annotation/freezed_annotation.dart';

part 'medical_event.freezed.dart';
part 'medical_event.g.dart';

enum EventType {
  VACCINE,
  CHECKUP,
  DENTAL,
  MEDICATION,
  OTHER,
}

enum EventStatus {
  UPCOMING,
  COMPLETED,
  CANCELLED,
}

enum EventTimeMode {
  fromTo,
  allDay,
  mealBased,
}

/// Trạng thái hiển thị trên UI — tính toán động dựa vào `finished` và thời gian
enum EventDisplayStatus {
  upcoming,
  ongoing,
  incomplete,
  finished,
  cancelled,
}

@freezed
class MedicalEvent with _$MedicalEvent {
  const MedicalEvent._();

  const factory MedicalEvent({
    required String id,
    @JsonKey(name: 'family_id') required String familyId,
    required String title,
    String? description,
    @JsonKey(name: 'event_type') required String eventType, // VACCINE, CHECKUP, etc.
    @JsonKey(name: 'start_time') required DateTime startTime,
    @JsonKey(name: 'end_time') required DateTime endTime,
    required String location,
    @JsonKey(name: 'creator_id') String? creatorId,
    @JsonKey(name: 'participant_ids') @Default([]) List<String> participantIds,
    @JsonKey(name: 'status') @Default('UPCOMING') String status,
    @JsonKey(name: 'medication_id') String? medicationId,
    @JsonKey(name: 'image_url') String? imageUrl,
    /// Biến bool xác định người dùng đã đánh dấu hoàn thành sự kiện
    @JsonKey(name: 'finished') @Default(false) bool finished,
    /// Chế độ thời gian: 'from_to' | 'all_day' | 'meal_based'
    @JsonKey(name: 'time_mode') @Default('from_to') String timeMode,
    /// Bữa ăn (chỉ dùng khi timeMode = 'meal_based'): 'breakfast' | 'lunch' | 'dinner' | 'snack'
    @JsonKey(name: 'meal_time') String? mealTime,
  }) = _MedicalEvent;

  factory MedicalEvent.fromJson(Map<String, dynamic> json) =>
      _$MedicalEventFromJson(json);

  /// Tính toán trạng thái hiển thị UI dựa vào `finished` và thời gian hiện tại.
  ///
  /// - `finished == true` → **finished** (Hoàn thành - xanh lá)
  /// - `finished == false` + `now < startTime` → **upcoming** (Sắp tới - xanh dương)
  /// - `finished == false` + `startTime <= now <= endTime` → **ongoing** (Đang diễn ra - cam)
  /// - `finished == false` + `now > endTime` → **incomplete** (Chưa hoàn thành - đỏ)
  /// - `status == 'CANCELLED'` → **cancelled**
  EventDisplayStatus get computedStatus {
    if (status == 'CANCELLED') return EventDisplayStatus.cancelled;
    if (finished) return EventDisplayStatus.finished;
    final now = DateTime.now();
    if (now.isBefore(startTime)) return EventDisplayStatus.upcoming;
    if (now.isAfter(endTime)) return EventDisplayStatus.incomplete;
    return EventDisplayStatus.ongoing;
  }

  /// True nếu event đang diễn ra hoặc sắp tới (dùng cho Simplified Mode filter)
  bool get isActiveOrUpcoming {
    final s = computedStatus;
    return s == EventDisplayStatus.upcoming || s == EventDisplayStatus.ongoing;
  }
}
