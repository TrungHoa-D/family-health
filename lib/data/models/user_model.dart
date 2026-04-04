import 'package:family_health/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.uid,
    super.displayName,
    super.email,
    super.photoUrl,
    super.phone,
    super.uiPreference,
  });

  factory UserModel.fromJson(Map<String, dynamic> json, String uid) {
    return UserModel(
      uid: uid,
      displayName: json['display_name'] as String?,
      email: json['email'] as String?,
      photoUrl: json['avatar_url'] as String?,
      phone: json['phone_number'] as String?,
      uiPreference: json['ui_preference'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'display_name': displayName ?? '',
      'email': email ?? '',
      'avatar_url': photoUrl ?? '',
      'phone_number': phone ?? '',
      'ui_preference': uiPreference ?? 'STANDARD',
    };
  }

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      uid: entity.uid,
      displayName: entity.displayName,
      email: entity.email,
      photoUrl: entity.photoUrl,
      phone: entity.phone,
      uiPreference: entity.uiPreference,
    );
  }
}
