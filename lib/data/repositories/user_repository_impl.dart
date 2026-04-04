import 'package:family_health/data/remote/datasources/firebase_firestore_datasource.dart';
import 'package:family_health/domain/entities/user_entity.dart';
import 'package:family_health/domain/repositories/user_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: UserRepository)
class UserRepositoryImpl implements UserRepository {
  UserRepositoryImpl(this._firestoreDataSource);
  final FirebaseFirestoreDataSource _firestoreDataSource;

  @override
  Future<void> syncUser(UserEntity user) async {
    await _firestoreDataSource.syncUser(user.uid, user.toJson());
  }

  @override
  Future<UserEntity?> getUser(String uid) async {
    final data = await _firestoreDataSource.getUserData(uid);
    if (data != null) {
      return UserEntity.fromJson(data);
    }
    return null;
  }
}
