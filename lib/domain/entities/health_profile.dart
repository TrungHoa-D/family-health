import 'package:freezed_annotation/freezed_annotation.dart';

part 'health_profile.freezed.dart';
part 'health_profile.g.dart';

@freezed
class HealthProfile with _$HealthProfile {
  const factory HealthProfile({
    required String height,
    required String weight,
    @JsonKey(name: 'blood_type') required String? bloodType,
    @JsonKey(name: 'is_rh_positive') @Default(true) bool isRhPositive,
    @JsonKey(name: 'is_male') @Default(true) bool isMale,
    @JsonKey(name: 'birth_date') DateTime? birthDate,
    @JsonKey(name: 'medical_history') @Default([]) List<String> medicalHistory,
    @JsonKey(name: 'other_disease') String? otherDisease,
    @JsonKey(name: 'anchor_times') @Default(AnchorTimes()) AnchorTimes anchorTimes,
  }) = _HealthProfile;

  factory HealthProfile.fromJson(Map<String, dynamic> json) =>
      _$HealthProfileFromJson(json);
}

@freezed
class AnchorTimes with _$AnchorTimes {
  const factory AnchorTimes({
    @Default('07:00') String breakfast,
    @Default('12:00') String lunch,
    @Default('19:00') String dinner,
    @Default('22:00') String sleep,
  }) = _AnchorTimes;

  factory AnchorTimes.fromJson(Map<String, dynamic> json) =>
      _$AnchorTimesFromJson(json);
}
