import 'package:family_health/data/remote/datasources/auth_data_source.dart';
import 'package:family_health/domain/entities/user_entity.dart';
import 'package:family_health/domain/repositories/auth_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._authDataSource);

  final AuthDataSource _authDataSource;

  @override
  Future<UserEntity> signInWithGoogle() {
    return _authDataSource.signInWithGoogle();
  }

  @override
  Future<UserEntity> signInWithEmailPassword(String email, String password) {
    return _authDataSource.signInWithEmailPassword(email, password);
  }

  @override
  Future<UserEntity> signUpWithEmailPassword(String email, String password) {
    return _authDataSource.signUpWithEmailPassword(email, password);
  }

  @override
  Stream<UserEntity?> authStateChanges() {
    return _authDataSource.authStateChanges();
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
