import 'package:family_health/domain/entities/user_entity.dart';
import 'package:family_health/domain/repositories/auth_repository.dart';
import 'package:injectable/injectable.dart';

class EmailSignInParams {
  const EmailSignInParams({required this.email, required this.password});
  final String email;
  final String password;
}

@injectable
class EmailSignInUseCase {
  EmailSignInUseCase(this._authRepository);

  final AuthRepository _authRepository;

  Future<UserEntity> call({required EmailSignInParams params}) {
    return _authRepository.signInWithEmailPassword(
      params.email,
      params.password,
    );
  }
}
