import 'dart:io';
import 'package:family_health/domain/repositories/user_repository.dart';
import 'package:family_health/domain/usecases/use_case.dart';
import 'package:injectable/injectable.dart';

class UpdateAvatarParams {
  UpdateAvatarParams({required this.uid, required this.image});
  final String uid;
  final File image;
}

@lazySingleton
class UpdateAvatarUseCase extends UseCase<String, UpdateAvatarParams> {
  UpdateAvatarUseCase(this._repository);
  final UserRepository _repository;

  @override
  Future<String> call({required UpdateAvatarParams params}) {
    return _repository.uploadAvatar(params.uid, params.image);
  }
}
