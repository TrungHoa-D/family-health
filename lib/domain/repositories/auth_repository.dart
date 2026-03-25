import 'package:family_health/domain/entities/user_entity.dart';

abstract class AuthRepository {
  Future<UserEntity> signInWithGoogle();
  Future<void> signOut();
  UserEntity? getCurrentUser();
}
