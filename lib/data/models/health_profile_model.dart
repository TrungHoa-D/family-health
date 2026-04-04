import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:family_health/domain/entities/health_profile.dart';

class HealthProfileModel {
  static HealthProfile fromJson(Map<String, dynamic> json) {
    return HealthProfile(
      height: json['height'] as String? ?? '',
      weight: json['weight'] as String? ?? '',
      bloodType: json['blood_type'] as String?,
      isRhPositive: json['is_rh_positive'] as bool? ?? true,
      isMale: json['is_male'] as bool? ?? true,
      birthDate: (json['birth_date'] as Timestamp?)?.toDate(),
      medicalHistory: (json['medical_history'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      otherDisease: json['other_disease'] as String?,
      anchorTimes: json['anchor_times'] != null
          ? AnchorTimesModel.fromJson(
              json['anchor_times'] as Map<String, dynamic>,
            )
          : const AnchorTimes(),
    );
  }

  static Map<String, dynamic> toJson(HealthProfile entity) {
    return {
      'height': entity.height,
      'weight': entity.weight,
      'blood_type': entity.bloodType,
      'is_rh_positive': entity.isRhPositive,
      'is_male': entity.isMale,
      'birth_date': entity.birthDate != null
          ? Timestamp.fromDate(entity.birthDate!)
          : null,
      'medical_history': entity.medicalHistory,
      'other_disease': entity.otherDisease,
      'anchor_times': AnchorTimesModel.toJson(entity.anchorTimes),
    };
  }
}

class AnchorTimesModel {
  static AnchorTimes fromJson(Map<String, dynamic> json) {
    return AnchorTimes(
      breakfast: json['breakfast'] as String? ?? '07:00',
      lunch: json['lunch'] as String? ?? '12:00',
      dinner: json['dinner'] as String? ?? '19:00',
      sleep: json['sleep'] as String? ?? '22:00',
    );
  }

  static Map<String, dynamic> toJson(AnchorTimes entity) {
    return {
      'breakfast': entity.breakfast,
      'lunch': entity.lunch,
      'dinner': entity.dinner,
      'sleep': entity.sleep,
    };
  }
}
