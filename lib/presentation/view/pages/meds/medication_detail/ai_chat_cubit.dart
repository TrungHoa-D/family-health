import 'package:family_health/domain/usecases/get_ai_response_usecase.dart';
import 'package:family_health/presentation/base/page_status.dart';
import 'package:family_health/presentation/cubit_base/base_cubit.dart';
import 'package:family_health/presentation/cubit_base/base_cubit_state.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

part 'ai_chat_cubit.freezed.dart';
part 'ai_chat_state.dart';

@injectable
class AIChatCubit extends BaseCubit<AIChatState> {
  AIChatCubit(this._getAIResponseUseCase) : super(const AIChatState());

  final GetAIResponseUseCase _getAIResponseUseCase;

  void init(String medicationName) {
    emit(state.copyWith(
      medicationName: medicationName,
      messages: [
        ChatMessage(
          content: 'Xin chào! Tôi là Trợ lý Sức khỏe AI. Bạn có muốn biết thêm thông tin về thuốc $medicationName không?',
          isUser: false,
        ),
      ],
    ));
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final newMessages = [
      ...state.messages,
      ChatMessage(content: text, isUser: true),
    ];

    emit(state.copyWith(
      messages: newMessages,
      isTyping: true,
    ));

    try {
      final prompt = '''
        Bạn là một Trợ lý Y khoa AI chuyên nghiệp. 
        Người dùng đang hỏi về thuốc: ${state.medicationName}.
        Câu hỏi của họ: "$text".
        
        Hãy trả lời một cách chính xác, tin cậy nhưng cũng thân thiện. 
        Lưu ý: Luôn kèm theo lời khuyên "Hãy tham khảo ý kiến bác sĩ trước khi thay đổi liều lượng".
        Sử dụng định dạng Markdown (bullet points, bold) để nội dung dễ đọc.
      ''';

      final response = await _getAIResponseUseCase(
        params: GetAIResponseParams(prompt: prompt),
      );

      emit(state.copyWith(
        messages: [
          ...state.messages,
          ChatMessage(content: response, isUser: false),
        ],
        isTyping: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        messages: [
          ...state.messages,
          ChatMessage(content: 'Rất tiếc, đã có lỗi xảy ra khi kết nối với AI: $e', isUser: false),
        ],
        isTyping: false,
      ));
    }
  }
}

@freezed
class ChatMessage with _$ChatMessage {
  const factory ChatMessage({
    required String content,
    required bool isUser,
    DateTime? timestamp,
  }) = _ChatMessage;
}
