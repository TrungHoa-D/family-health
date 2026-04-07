import 'package:family_health/domain/entities/user_entity.dart';
import 'package:family_health/domain/repositories/user_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class WatchUserUseCase {
  WatchUserUseCase(this._userRepository);
  final UserRepository _userRepository;

  Stream<UserEntity?> call({required String params}) {
    return _userRepository.watchUser(params);
  }
}
