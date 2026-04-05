import 'package:family_health/domain/entities/family_group.dart';
import 'package:family_health/domain/repositories/family_repository_interface.dart';
import 'package:family_health/domain/usecases/use_case.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetFamilyUseCase extends UseCase<FamilyGroup?, String> {
  GetFamilyUseCase(this._repository);
  final FamilyRepository _repository;

  @override
  Future<FamilyGroup?> call({required String params}) {
    return _repository.getFamilyGroup(params);
  }
}
