import 'package:freezed_annotation/freezed_annotation.dart';

part 'health_profile.freezed.dart';

@freezed
class HealthProfile with _$HealthProfile {
  const factory HealthProfile({
    required String height,
    required String weight,
    required String? bloodType,
    @Default(true) bool isRhPositive,
    @Default(true) bool isMale,
    DateTime? birthDate,
    @Default([]) List<String> medicalHistory,
    String? otherDisease,
    @Default(AnchorTimes()) AnchorTimes anchorTimes,
  }) = _HealthProfile;
}

@freezed
class AnchorTimes with _$AnchorTimes {
  const factory AnchorTimes({
    @Default('07:00') String breakfast,
    @Default('12:00') String lunch,
    @Default('19:00') String dinner,
    @Default('22:00') String sleep,
  }) = _AnchorTimes;
}
