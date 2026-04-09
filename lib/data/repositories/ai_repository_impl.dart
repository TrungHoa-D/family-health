import 'dart:io';
import 'package:family_health/data/remote/datasources/firebase_firestore_datasource.dart';
import 'package:family_health/domain/entities/ai_chat_message.dart';
import 'package:family_health/domain/repositories/ai_repository_interface.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: AIRepository)
class AIRepositoryImpl implements AIRepository {
  AIRepositoryImpl(this._firestoreDataSource);

  final FirebaseFirestoreDataSource _firestoreDataSource;

  @override
  Future<String> getAIResponse(String prompt, {File? image}) async {
    if (!dotenv.isInitialized) {
      throw Exception(
          'Environment variables not initialized. Please ensure .env file exists and is valid.');
    }

    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null ||
        apiKey.isEmpty ||
        apiKey == 'YOUR_GEMINI_API_KEY_HERE') {
      throw Exception(
          'Gemini API Key is missing or invalid. Please update your .env file.');
    }

    final model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: apiKey,
      systemInstruction: Content.system(
        'Bạn là Trợ lý Y tế ảo chuyên nghiệp của ứng dụng Family Health. '
        'Nhiệm vụ của bạn là hỗ trợ người dùng và người cao tuổi quản lý sức khỏe, nhắc nhở thuốc và giải đáp thắc mắc y tế cơ bản. '
        'Quy tắc phản hồi:\n'
        '1. Luôn sử dụng tiếng Việt thân thiện, lịch sự và dễ hiểu.\n'
        '2. Câu trả lời cần ngắn gọn, đi thẳng vào vấn đề.\n'
        '3. Nếu người dùng hỏi về bệnh nghiêm trọng, hãy khuyên họ đi khám bác sĩ hoặc gọi cấp cứu ngay lập tức.\n'
        '4. Luôn khuyến khích lối sống lành mạnh và tuân thủ liều lượng thuốc đã kê toa.',
      ),
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

  @override
  Stream<List<AIChatMessage>> getChatHistory(String userId) {
    return _firestoreDataSource.watchAIChatMessages(userId).map(
          (list) => list.map((json) => AIChatMessage.fromJson(json)).toList(),
        );
  }

  @override
  Future<void> saveChatMessage(AIChatMessage message) {
    return _firestoreDataSource.saveAIChatMessage(message.id, message.toJson());
  }
}
