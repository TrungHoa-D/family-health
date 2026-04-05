import 'package:family_health/domain/entities/user_entity.dart';
import 'package:family_health/domain/repositories/auth_repository.dart';
import 'package:family_health/domain/usecases/use_case.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class WatchAuthStatusUseCase extends UseCaseStream<UserEntity?, void> {
  WatchAuthStatusUseCase(this._repository);
  final AuthRepository _repository;

  @override
  Stream<UserEntity?> call(void params) {
    return _repository.authStateChanges();
  }
}
