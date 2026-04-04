import 'package:family_health/domain/entities/health_profile.dart';
import 'package:family_health/domain/repositories/health_repository.dart';
import 'package:family_health/domain/usecases/use_case.dart';
import 'package:injectable/injectable.dart';

class SaveHealthProfileParams {
  SaveHealthProfileParams({required this.uid, required this.profile});
  final String uid;
  final HealthProfile profile;
}

@injectable
class SaveHealthProfileUseCase
    implements UseCase<void, SaveHealthProfileParams> {
  SaveHealthProfileUseCase(this._healthRepository);
  final HealthRepository _healthRepository;

  @override
  Future<void> call({required SaveHealthProfileParams params}) async {
    return _healthRepository.saveHealthProfile(params.uid, params.profile);
  }
}
