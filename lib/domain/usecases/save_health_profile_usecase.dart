import 'package:family_health/domain/entities/health_profile.dart';
import 'package:family_health/domain/repositories/health_repository.dart';
import 'package:family_health/domain/usecases/use_case.dart';
import 'package:injectable/injectable.dart';

class SaveHealthProfileParams {
  final String uid;
  final HealthProfile profile;

  SaveHealthProfileParams({required this.uid, required this.profile});
}

@injectable
class SaveHealthProfileUseCase implements UseCase<void, SaveHealthProfileParams> {
  final HealthRepository _healthRepository;

  SaveHealthProfileUseCase(this._healthRepository);

  @override
  Future<void> call({required SaveHealthProfileParams params}) async {
    return _healthRepository.saveHealthProfile(params.uid, params.profile);
  }
}
