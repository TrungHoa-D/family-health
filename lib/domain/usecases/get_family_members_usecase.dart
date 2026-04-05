import 'package:family_health/domain/entities/user_entity.dart';
import 'package:family_health/domain/repositories/user_repository.dart';
import 'package:family_health/domain/usecases/use_case.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetFamilyMembersUseCase extends UseCase<List<UserEntity>, List<String>> {
  GetFamilyMembersUseCase(this._repository);
  final UserRepository _repository;

  @override
  Future<List<UserEntity>> call({required List<String> params}) {
    return _repository.getUsers(params);
  }
}
