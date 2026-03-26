import 'package:injectable/injectable.dart';
import 'package:family_health/domain/entities/user_entity.dart';
import 'package:family_health/domain/repositories/auth_repository.dart';
import 'package:family_health/domain/usecases/use_case.dart';

@injectable
class CheckAuthStatusUseCase implements UseCase<UserEntity?, void> {
  CheckAuthStatusUseCase(this._authRepository);

  final AuthRepository _authRepository;

  @override
  Future<UserEntity?> call({required void params}) async {
    return _authRepository.getCurrentUser();
  }
}
