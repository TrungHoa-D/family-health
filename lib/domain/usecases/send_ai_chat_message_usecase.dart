import 'package:family_health/domain/entities/ai_chat_message.dart';
import 'package:family_health/domain/repositories/ai_repository_interface.dart';
import 'package:family_health/domain/usecases/use_case.dart';
import 'package:injectable/injectable.dart';

@injectable
class SendAIChatMessageUseCase extends UseCase<void, AIChatMessage> {
  SendAIChatMessageUseCase(this._repository);
  final AIRepository _repository;

  @override
  Future<void> call({required AIChatMessage params}) {
    return _repository.saveChatMessage(params);
  }
}
