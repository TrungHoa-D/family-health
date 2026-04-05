import 'dart:io';
import 'package:family_health/data/remote/datasources/firebase_firestore_datasource.dart';
import 'package:family_health/data/remote/datasources/firebase_storage_datasource.dart';
import 'package:family_health/domain/entities/user_entity.dart';
import 'package:family_health/domain/repositories/user_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: UserRepository)
class UserRepositoryImpl implements UserRepository {
  UserRepositoryImpl(this._firestoreDataSource, this._storageDataSource);
  final FirebaseFirestoreDataSource _firestoreDataSource;
  final FirebaseStorageDataSource _storageDataSource;

  @override
  Future<void> syncUser(UserEntity user) async {
    await _firestoreDataSource.syncUser(user.uid, user.toJson());
  }

  @override
  Future<UserEntity?> getUser(String uid) async {
    final data = await _firestoreDataSource.getUserData(uid);
    if (data != null) {
      // The id (uid) is usually not in the Firestore document body but we keep it in our entity
      return UserEntity.fromJson({...data, 'uid': uid});
    }
    return null;
  }

  @override
  Future<String> uploadAvatar(String uid, File image) async {
    final path = 'avatars/$uid.jpg';
    final url = await _storageDataSource.uploadFile(path, image);
    
    // Auto-sync user with new avatar URL
    final currentUser = await getUser(uid);
    if (currentUser != null) {
      await syncUser(currentUser.copyWith(avatarUrl: url));
    }
    
    return url;
  }
}
