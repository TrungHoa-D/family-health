import 'dart:io';
import '../entities/ai_chat_message.dart';

abstract class AIRepository {
  Future<String> getAIResponse(String prompt, {File? image});
  
  // New methods for AI Chat History
  Stream<List<AIChatMessage>> getChatHistory(String userId);
  Future<void> saveChatMessage(AIChatMessage message);
}
