import 'dart:io';

abstract class AIRepository {
  Future<String> getAIResponse(String prompt, {File? image});
}
