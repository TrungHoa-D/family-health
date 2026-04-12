import 'package:family_health/domain/repositories/chat_repository_interface.dart';
import 'package:family_health/domain/usecases/use_case.dart';
import 'package:injectable/injectable.dart';

class EditMessageParams {
  final String id;
  final String newContent;

  EditMessageParams({required this.id, required this.newContent});
}

@injectable
class EditMessageUseCase implements UseCase<void, EditMessageParams> {
  EditMessageUseCase(this._repository);
  final ChatRepository _repository;

  @override
  Future<void> call({required EditMessageParams params}) {
    return _repository.updateMessage(params.id, params.newContent);
  }
}
