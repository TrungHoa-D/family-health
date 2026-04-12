import 'dart:io';

import 'package:family_health/domain/repositories/chat_repository_interface.dart';
import 'package:family_health/domain/usecases/use_case.dart';
import 'package:injectable/injectable.dart';

class UploadChatImagesParams {
  final String familyId;
  final List<File> files;

  UploadChatImagesParams({required this.familyId, required this.files});
}

@injectable
class UploadChatImagesUseCase
    implements UseCase<List<String>, UploadChatImagesParams> {
  UploadChatImagesUseCase(this._repository);
  final ChatRepository _repository;

  @override
  Future<List<String>> call({required UploadChatImagesParams params}) {
    return _repository.uploadChatImages(params.familyId, params.files);
  }
}
