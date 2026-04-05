import 'package:family_health/domain/entities/chat_message.dart';
import 'package:family_health/domain/repositories/chat_repository_interface.dart';
import 'package:family_health/domain/usecases/use_case.dart';
import 'package:injectable/injectable.dart';

@injectable
class SendMessageUseCase implements UseCase<void, ChatMessage> {
  SendMessageUseCase(this._repository);
  final ChatRepository _repository;

  @override
  Future<void> call({required ChatMessage params}) {
    return _repository.sendMessage(params);
  }
}
