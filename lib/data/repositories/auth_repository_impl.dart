import 'package:injectable/injectable.dart';
import 'package:family_health/data/remote/datasources/auth_data_source.dart';
import 'package:family_health/domain/entities/user_entity.dart';
import 'package:family_health/domain/repositories/auth_repository.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._authDataSource);

  final AuthDataSource _authDataSource;

  @override
  Future<UserEntity> signInWithGoogle() {
    return _authDataSource.signInWithGoogle();
  }

  @override
  Future<void> signOut() {
    return _authDataSource.signOut();
  }

  @override
  UserEntity? getCurrentUser() {
    return _authDataSource.getCurrentUser();
  }
}
