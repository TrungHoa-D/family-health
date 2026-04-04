import 'package:family_health/domain/entities/user_entity.dart';
import 'package:family_health/domain/repositories/auth_repository.dart';
import 'package:family_health/domain/usecases/email_sign_in_usecase.dart';
import 'package:injectable/injectable.dart';

@injectable
class EmailSignUpUseCase {
  const EmailSignUpUseCase(this._authRepository);

  final AuthRepository _authRepository;

  Future<UserEntity> call({required EmailSignInParams params}) async {
    return _authRepository.signUpWithEmailPassword(
      params.email,
      params.password,
    );
  }
}
