import 'package:family_health/domain/entities/family_group.dart';

abstract class FamilyRepository {
  Future<void> createFamilyGroup(FamilyGroup family);
  Future<FamilyGroup?> getFamilyGroup(String id);
  Future<FamilyGroup?> getFamilyByInviteCode(String code);
  Future<void> updateFamilyGroup(FamilyGroup family);
  Future<void> deleteFamilyGroup(String id);
  Future<void> joinFamilyGroup(String userId, String invitationCode);
}
