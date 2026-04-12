import 'package:family_health/domain/repositories/chat_repository_interface.dart';
import 'package:family_health/domain/usecases/use_case.dart';
import 'package:injectable/injectable.dart';

@injectable
class DeleteMessageUseCase implements UseCase<void, String> {
  DeleteMessageUseCase(this._repository);
  final ChatRepository _repository;

  @override
  Future<void> call({required String params}) {
    return _repository.deleteMessage(params);
  }
}
