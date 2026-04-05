import 'package:family_health/presentation/view/pages/chat/chat_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatCubit extends Cubit<ChatState> {
  ChatCubit() : super(const ChatState()) {
    _loadMockMessages();
  }

  void _loadMockMessages() {
    final now = DateTime.now();
    final mockMessages = [
      ChatMessageModel(
        id: '1',
        content: 'Bố đã uống thuốc huyết áp rồi nhé',
        time: DateTime(now.year, now.month, now.day, 8, 30),
        senderType: MessageSenderType.otherMember,
        senderName: 'Bố',
        avatarUrl: 'B',
      ),
      ChatMessageModel(
        id: '2',
        content: 'Tốt lắm Bố ạ! 😊',
        time: DateTime(now.year, now.month, now.day, 8, 32),
        senderType: MessageSenderType.me,
      ),
      ChatMessageModel(
        id: '3',
        content: 'Nhịp tim của Bố ổn định\nĐã cập nhật lúc 09:00 AM',
        time: DateTime(now.year, now.month, now.day, 9, 00),
        senderType: MessageSenderType.systemAi,
      ),
      ChatMessageModel(
        id: '4',
        content:
            'Con vừa kiểm tra chỉ số tim mạch của bố trên app. Mọi thứ đều rất tuyệt vời.',
        time: DateTime(now.year, now.month, now.day, 9, 05),
        senderType: MessageSenderType.me,
      ),
      ChatMessageModel(
        id: '5',
        content:
            'Tuyệt quá! Trưa nay chị sẽ ghé qua nấu cơm cho Bố nhé. Có ai dặn mua gì không?',
        time: DateTime(now.year, now.month, now.day, 9, 12),
        senderType: MessageSenderType.otherMember,
        senderName: 'Chị Lan',
        avatarUrl: 'L',
      ),
    ];

    emit(state.copyWith(messages: mockMessages));
  }

  void sendMessage(String text) {
    if (text.trim().isEmpty) {
      return;
    }

    final newMessage = ChatMessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: text,
      time: DateTime.now(),
      senderType: MessageSenderType.me,
    );

    emit(
      state.copyWith(
        messages: [...state.messages, newMessage],
      ),
    );
  }
}
