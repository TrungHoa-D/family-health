import 'package:family_health/domain/repositories/user_repository.dart';
import 'package:family_health/domain/usecases/use_case.dart';
import 'package:injectable/injectable.dart';

class UpdateUIPreferenceParams {
  const UpdateUIPreferenceParams({
    required this.uid,
    required this.preference,
  });
  final String uid;
  final String preference; // 'standard' or 'simplified'
}

@injectable
class UpdateUIPreferenceUseCase extends UseCase<void, UpdateUIPreferenceParams> {
  UpdateUIPreferenceUseCase(this._repository);
  final UserRepository _repository;

  @override
  Future<void> call({required UpdateUIPreferenceParams params}) {
    return _repository.updateUIPreference(params.uid, params.preference);
  }
}
