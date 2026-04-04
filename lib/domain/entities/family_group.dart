import 'package:freezed_annotation/freezed_annotation.dart';

part 'family_group.freezed.dart';
part 'family_group.g.dart';

@freezed
class FamilyGroup with _$FamilyGroup {
  const factory FamilyGroup({
    required String id,
    required String name,
    required String invitationCode,
    @Default([]) List<String> adminIds,
    @Default([]) List<String> memberIds,
    DateTime? createdAt,
  }) = _FamilyGroup;

  factory FamilyGroup.fromJson(Map<String, dynamic> json) =>
      _$FamilyGroupFromJson(json);
}
