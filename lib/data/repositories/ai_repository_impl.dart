import 'dart:io';
import 'package:family_health/domain/repositories/ai_repository_interface.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: AIRepository)
class AIRepositoryImpl implements AIRepository {
  AIRepositoryImpl();

  @override
  Future<String> getAIResponse(String prompt, {File? image}) async {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null || apiKey.isEmpty || apiKey == 'YOUR_GEMINI_API_KEY_HERE') {
      throw Exception('Gemini API Key is missing or invalid. Please update your .env file.');
    }

    final model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: apiKey,
    );

    final content = [
      Content.multi([
        TextPart(prompt),
        if (image != null) DataPart('image/jpeg', await image.readAsBytes()),
      ]),
    ];

    final response = await model.generateContent(content);
    return response.text ?? 'No response from AI.';
  }
}
