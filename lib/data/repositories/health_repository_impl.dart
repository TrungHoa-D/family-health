import 'package:family_health/data/remote/datasources/firebase_firestore_datasource.dart';
import 'package:family_health/domain/entities/health_profile.dart';
import 'package:family_health/domain/repositories/health_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: HealthRepository)
class HealthRepositoryImpl implements HealthRepository {
  HealthRepositoryImpl(this._dataSource);
  final FirebaseFirestoreDataSource _dataSource;

  @override
  Future<void> saveHealthProfile(String userId, HealthProfile profile) {
    return _dataSource.saveHealthProfile(userId, profile.toJson());
  }

  @override
  Future<HealthProfile?> getHealthProfile(String userId) async {
    final data = await _dataSource.getHealthProfile(userId);
    return data != null ? HealthProfile.fromJson(data) : null;
  }
}
