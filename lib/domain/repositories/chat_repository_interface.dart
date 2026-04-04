import 'package:family_health/domain/entities/chat_message.dart';

abstract class ChatRepository {
  Future<void> sendMessage(ChatMessage message);
  Stream<List<ChatMessage>> watchChatMessages(String familyId);
}
