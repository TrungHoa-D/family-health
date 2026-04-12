import 'dart:io';
import 'package:family_health/domain/entities/user_entity.dart';

abstract class UserRepository {
  Future<void> syncUser(UserEntity user);
  Future<UserEntity?> getUser(String uid);
  Future<List<UserEntity>> getUsers(List<String> uids);
  Future<void> updateUIPreference(String uid, String preference);
  Future<String> uploadAvatar(String uid, File image);
  Stream<UserEntity?> watchUser(String uid);
  Future<void> updateFcmToken(String uid, String token);
  Future<void> removeFcmToken(String uid, String token);
}
