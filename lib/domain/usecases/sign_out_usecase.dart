import 'package:injectable/injectable.dart';
import 'package:family_health/domain/repositories/auth_repository.dart';
import 'package:family_health/domain/usecases/use_case.dart';

@injectable
class SignOutUseCase implements UseCase<void, void> {
  SignOutUseCase(this._authRepository);

  final AuthRepository _authRepository;

  @override
  Future<void> call({required void params}) {
    return _authRepository.signOut();
  }
}
