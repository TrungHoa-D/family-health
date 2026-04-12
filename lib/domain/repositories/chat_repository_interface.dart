import 'dart:io';

import 'package:family_health/domain/entities/chat_message.dart';

abstract class ChatRepository {
  Future<void> sendMessage(ChatMessage message);
  Stream<List<ChatMessage>> watchChatMessages(String familyId);
  Future<List<String>> uploadChatImages(String familyId, List<File> files);
  Future<void> deleteMessage(String id);
  Future<void> updateMessage(String id, String content);
}
