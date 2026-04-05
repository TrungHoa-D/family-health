import 'package:freezed_annotation/freezed_annotation.dart';

part 'family_group.freezed.dart';
part 'family_group.g.dart';

@freezed
class FamilyGroup with _$FamilyGroup {
  const factory FamilyGroup({
    @JsonKey(name: 'family_id') required String familyId,
    @JsonKey(name: 'family_name') required String familyName,
    @JsonKey(name: 'invitationCode') required String invitationCode,
    @JsonKey(name: 'admin_id') required String adminId,
    @JsonKey(name: 'member_ids') @Default([]) List<String> memberIds,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _FamilyGroup;

  factory FamilyGroup.fromJson(Map<String, dynamic> json) =>
      _$FamilyGroupFromJson(json);
}
