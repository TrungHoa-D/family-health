import 'package:family_health/domain/entities/user_entity.dart';
import 'package:family_health/domain/repositories/auth_repository.dart';
import 'package:family_health/domain/usecases/use_case.dart';
import 'package:injectable/injectable.dart';

@injectable
class GoogleSignInUseCase implements UseCase<UserEntity, void> {
  GoogleSignInUseCase(this._authRepository);

  final AuthRepository _authRepository;

  @override
  Future<UserEntity> call({required void params}) {
    return _authRepository.signInWithGoogle();
  }
}
