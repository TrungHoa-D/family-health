import 'package:family_health/domain/entities/user_entity.dart';

class UserModel {
  UserModel._();

  static UserEntity fromJson(Map<String, dynamic> json, String uid) {
    return UserEntity(
      uid: uid,
      displayName: json['display_name'] as String?,
      email: json['email'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      phoneNumber: json['phone_number'] as String?,
      uiPreference: json['ui_preference'] as String?,
      familyId: json['family_id'] as String?,
    );
  }

  static Map<String, dynamic> toJson(UserEntity entity) {
    return {
      'display_name': entity.displayName ?? '',
      'email': entity.email ?? '',
      'avatar_url': entity.avatarUrl ?? '',
      'phone_number': entity.phoneNumber ?? '',
      'ui_preference': entity.uiPreference ?? 'STANDARD',
      'family_id': entity.familyId ?? '',
    };
  }

  static UserEntity fromEntity(UserEntity entity) {
    return entity;
  }
}
