import 'package:family_health/domain/entities/ai_chat_message.dart';
import 'package:family_health/domain/repositories/ai_repository_interface.dart';
import 'package:family_health/domain/usecases/use_case.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetAIChatHistoryUseCase extends UseCase<Stream<List<AIChatMessage>>, String> {
  GetAIChatHistoryUseCase(this._repository);
  final AIRepository _repository;

  @override
  Future<Stream<List<AIChatMessage>>> call({required String params}) async {
    return _repository.getChatHistory(params);
  }
}
