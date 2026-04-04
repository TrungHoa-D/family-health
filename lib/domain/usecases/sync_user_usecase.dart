import 'package:family_health/domain/entities/user_entity.dart';
import 'package:family_health/domain/repositories/user_repository.dart';
import 'package:family_health/domain/usecases/use_case.dart';
import 'package:injectable/injectable.dart';

@injectable
class SyncUserUseCase implements UseCase<void, UserEntity> {
  SyncUserUseCase(this._userRepository);
  final UserRepository _userRepository;

  @override
  Future<void> call({required UserEntity params}) async {
    return _userRepository.syncUser(params);
  }
}
