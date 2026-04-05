import 'package:family_health/domain/entities/chat_message.dart';
import 'package:family_health/domain/repositories/chat_repository_interface.dart';
import 'package:family_health/domain/usecases/use_case.dart';
import 'package:injectable/injectable.dart';

@injectable
class WatchChatMessagesUseCase implements UseCase<Stream<List<ChatMessage>>, String> {
  WatchChatMessagesUseCase(this._repository);
  final ChatRepository _repository;

  @override
  Future<Stream<List<ChatMessage>>> call({required String params}) async {
    return _repository.watchChatMessages(params);
  }
}
