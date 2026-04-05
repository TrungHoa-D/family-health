import 'package:family_health/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Stream<UserEntity?> authStateChanges();
  Future<UserEntity> signInWithGoogle();
  Future<UserEntity> signInWithEmailPassword(String email, String password);
  Future<UserEntity> signUpWithEmailPassword(String email, String password);
  Future<void> signOut();
  UserEntity? getCurrentUser();
}
