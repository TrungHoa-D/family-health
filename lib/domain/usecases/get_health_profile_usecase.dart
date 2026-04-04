import 'package:family_health/domain/entities/health_profile.dart';
import 'package:family_health/domain/repositories/health_repository.dart';
import 'package:family_health/domain/usecases/use_case.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetHealthProfileUseCase implements UseCase<HealthProfile?, String> {
  final HealthRepository _healthRepository;

  GetHealthProfileUseCase(this._healthRepository);

  @override
  Future<HealthProfile?> call({required String params}) async {
    return _healthRepository.getHealthProfile(params);
  }
}
