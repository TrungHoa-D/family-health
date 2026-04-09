import 'dart:async';
import 'package:family_health/domain/entities/ai_chat_message.dart';
import 'package:family_health/domain/repositories/auth_repository.dart';
import 'package:family_health/domain/usecases/get_ai_chat_history_usecase.dart';
import 'package:family_health/domain/usecases/get_ai_response_usecase.dart';
import 'package:family_health/domain/usecases/send_ai_chat_message_usecase.dart';
import 'package:family_health/presentation/base/page_status.dart';
import 'package:family_health/presentation/cubit_base/base_cubit.dart';
import 'package:family_health/presentation/cubit_base/base_cubit_state.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

part 'ai_chat_cubit.freezed.dart';
part 'ai_chat_state.dart';

@injectable
class AIChatSupportCubit extends BaseCubit<AIChatSupportState> {
  AIChatSupportCubit(
    this._authRepository,
    this._getAIChatHistoryUseCase,
    this._sendAIChatMessageUseCase,
    this._getAIResponseUseCase,
  ) : super(const AIChatSupportState());

  final AuthRepository _authRepository;
  final GetAIChatHistoryUseCase _getAIChatHistoryUseCase;
  final SendAIChatMessageUseCase _sendAIChatMessageUseCase;
  final GetAIResponseUseCase _getAIResponseUseCase;

  StreamSubscription? _historySubscription;

  Future<void> init() async {
    final user = _authRepository.getCurrentUser();
    if (user == null) return;

    emit(state.copyWith(userId: user.uid, pageStatus: PageStatus.Loading));

    try {
      _historySubscription?.cancel();
      final stream = await _getAIChatHistoryUseCase.call(params: user.uid);
      _historySubscription = stream.listen((messages) {
        if (!isClosed) {
          emit(state.copyWith(
            messages: messages,
            pageStatus: PageStatus.Loaded,
          ));
        }
      });
    } catch (e) {
      emit(state.copyWith(
        pageStatus: PageStatus.Error,
        pageErrorMessage: e.toString(),
      ));
    }
  }

  Future<void> sendMessage(String text) async {
    final uid = state.userId;
    if (uid == null || text.trim().isEmpty) return;

    final userMessage = AIChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: uid,
      role: 'user',
      content: text,
      timestamp: DateTime.now(),
    );

    // Save user message
    await _sendAIChatMessageUseCase.call(params: userMessage);

    emit(state.copyWith(isTyping: true));

    try {
      // Prepare context from history
      final historyContext = state.messages.take(10).map((m) => '${m.role}: ${m.content}').join('\n');
      
      final prompt = '''
        Bạn là một Trợ lý Y khoa AI chuyên nghiệp và thân thiện. 
        Hãy trả lời các câu hỏi về sức khỏe một cách chính xác.
        Lưu ý quan trọng: Luôn nhắc nhở người dùng "Hãy tham khảo ý kiến bác sĩ chuyên khoa để có chẩn đoán chính xác nhất".
        Sử dụng định dạng Markdown cho câu trả lời.

        Lịch sử trò chuyện gần đây:
        $historyContext

        Câu hỏi mới của người dùng: "$text"
      ''';

      final response = await _getAIResponseUseCase.call(
        params: GetAIResponseParams(prompt: prompt),
      );

      final assistantMessage = AIChatMessage(
        id: (DateTime.now().millisecondsSinceEpoch + 1).toString(),
        userId: uid,
        role: 'assistant',
        content: response,
        timestamp: DateTime.now(),
      );

      // Save assistant message
      await _sendAIChatMessageUseCase.call(params: assistantMessage);
    } catch (e) {
      // Handle error by showing a message
      final errorMessage = AIChatMessage(
        id: (DateTime.now().millisecondsSinceEpoch + 2).toString(),
        userId: uid,
        role: 'assistant',
        content: 'Rất tiếc, tôi đang gặp khó khăn khi kết nối. Vui lòng thử lại sau. (Lỗi: $e)',
        timestamp: DateTime.now(),
      );
      await _sendAIChatMessageUseCase.call(params: errorMessage);
    } finally {
      emit(state.copyWith(isTyping: false));
    }
  }

  @override
  Future<void> close() {
    _historySubscription?.cancel();
    return super.close();
  }
}
