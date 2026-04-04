import 'package:family_health/domain/entities/user_entity.dart';

abstract class UserRepository {
  Future<void> syncUser(UserEntity user);
  Future<UserEntity?> getUser(String uid);
}
