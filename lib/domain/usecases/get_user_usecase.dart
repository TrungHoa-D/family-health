import 'package:family_health/domain/entities/user_entity.dart';
import 'package:family_health/domain/repositories/user_repository.dart';
import 'package:family_health/domain/usecases/use_case.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetUserUseCase implements UseCase<UserEntity?, String> {
  GetUserUseCase(this._userRepository);
  final UserRepository _userRepository;

  @override
  Future<UserEntity?> call({required String params}) async {
    return _userRepository.getUser(params);
  }
}
