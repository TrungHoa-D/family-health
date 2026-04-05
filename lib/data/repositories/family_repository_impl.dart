import 'package:family_health/data/remote/datasources/firebase_firestore_datasource.dart';
import 'package:family_health/domain/entities/family_group.dart';
import 'package:family_health/domain/repositories/family_repository_interface.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: FamilyRepository)
class FamilyRepositoryImpl implements FamilyRepository {
  FamilyRepositoryImpl(this._dataSource);
  final FirebaseFirestoreDataSource _dataSource;

  @override
  Future<void> createFamilyGroup(FamilyGroup family) {
    return _dataSource.createFamilyGroup(family.familyId, family.toJson());
  }

  @override
  Future<FamilyGroup?> getFamilyGroup(String id) async {
    final data = await _dataSource.getFamilyGroup(id);
    return data != null ? FamilyGroup.fromJson(data) : null;
  }

  @override
  Future<FamilyGroup?> getFamilyByInviteCode(String code) async {
    final data = await _dataSource.getFamilyByInviteCode(code);
    return data != null ? FamilyGroup.fromJson(data) : null;
  }

  @override
  Future<void> updateFamilyGroup(FamilyGroup family) {
    return _dataSource.updateFamilyGroup(family.familyId, family.toJson());
  }

  @override
  Future<void> joinFamilyGroup(String userId, String invitationCode) async {
    final family = await getFamilyByInviteCode(invitationCode);
    if (family == null) {
      throw Exception('Không tìm thấy nhóm gia đình với mã mời này.');
    }

    if (family.memberIds.contains(userId) || family.adminId == userId) {
      return; // Đã là thành viên
    }

    final updatedFamily = family.copyWith(
      memberIds: [...family.memberIds, userId],
    );
    await updateFamilyGroup(updatedFamily);
  }
}
