import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_entity.freezed.dart';
part 'user_entity.g.dart';

@freezed
class UserEntity with _$UserEntity {
  const factory UserEntity({
    required String uid,
    @JsonKey(name: 'display_name') String? displayName,
    String? email,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
    @JsonKey(name: 'phone_number') String? phoneNumber,
    @JsonKey(name: 'ui_preference') String? uiPreference,
    @JsonKey(name: 'family_id') String? familyId,
  }) = _UserEntity;

  factory UserEntity.fromJson(Map<String, dynamic> json) =>
      _$UserEntityFromJson(json);
}
