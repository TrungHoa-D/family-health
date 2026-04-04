import 'package:family_health/data/models/user_model.dart';
import 'package:family_health/data/remote/datasources/firebase_firestore_datasource.dart';
import 'package:family_health/domain/entities/user_entity.dart';
import 'package:family_health/domain/repositories/user_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: UserRepository)
class UserRepositoryImpl implements UserRepository {
  final FirebaseFirestoreDataSource _firestoreDataSource;

  UserRepositoryImpl(this._firestoreDataSource);

  @override
  Future<void> syncUser(UserEntity user) async {
    final userModel = UserModel.fromEntity(user);
    await _firestoreDataSource.syncUser(user.uid, userModel.toJson());
  }

  @override
  Future<UserEntity?> getUser(String uid) async {
    final data = await _firestoreDataSource.getUserData(uid);
    if (data != null) {
      return UserModel.fromJson(data, uid);
    }
    return null;
  }
}
