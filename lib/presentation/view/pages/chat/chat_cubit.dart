import 'dart:async';

import 'package:family_health/domain/entities/chat_message.dart';
import 'package:family_health/domain/usecases/get_user_usecase.dart';
import 'package:family_health/domain/usecases/send_message_usecase.dart';
import 'package:family_health/domain/usecases/watch_chat_messages_usecase.dart';
import 'package:family_health/presentation/base/page_status.dart';
import 'package:family_health/presentation/cubit_base/base_cubit.dart';
import 'package:family_health/presentation/view/pages/chat/chat_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:injectable/injectable.dart';

@injectable
class ChatCubit extends BaseCubit<ChatState> {
  ChatCubit(
    this._watchChatMessagesUseCase,
    this._sendMessageUseCase,
    this._getUserUseCase, {
    FirebaseAuth? firebaseAuth,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        super(const ChatState()) {
    _init();
  }

  final WatchChatMessagesUseCase _watchChatMessagesUseCase;
  final SendMessageUseCase _sendMessageUseCase;
  final GetUserUseCase _getUserUseCase;
  final FirebaseAuth _firebaseAuth;

  StreamSubscription? _messagesSubscription;

  Future<void> _init() async {
    emit(state.copyWith(pageStatus: PageStatus.Loading));

    try {
      final user = _firebaseAuth.currentUser;
      if (user == null) return;

      final userEntity = await _getUserUseCase.call(params: user.uid);
      final familyId = userEntity?.familyId;

      if (familyId == null) {
        emit(state.copyWith(
          pageStatus: PageStatus.Loaded,
          hasFamilyGroup: false,
        ));
        return;
      }

      emit(state.copyWith(
        currentFamilyId: familyId,
        currentUserId: user.uid,
        hasFamilyGroup: true,
      ));

      _messagesSubscription?.cancel();
      final messageStream = await _watchChatMessagesUseCase.call(params: familyId);
      _messagesSubscription = messageStream.listen((messages) {
        // Firestore descending: true -> latest first. 
        // ListView.builder handles it or we sort ascending for normal chat view?
        // Usually chat displays oldest at top, latest at bottom.
        final sortedMessages = List<ChatMessage>.from(messages)
          ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

        emit(state.copyWith(
          messages: sortedMessages,
          pageStatus: PageStatus.Loaded,
        ));
      });
    } catch (e) {
      emit(state.copyWith(
        pageStatus: PageStatus.Error,
        pageErrorMessage: e.toString(),
      ));
    }
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty || state.currentFamilyId == null || state.currentUserId == null) {
      return;
    }

    try {
      final userEntity = await _getUserUseCase.call(params: state.currentUserId!);
      
      final message = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        familyId: state.currentFamilyId!,
        senderId: state.currentUserId!,
        senderName: userEntity?.displayName ?? 'Thành viên',
        senderAvatarUrl: userEntity?.avatarUrl,
        content: text,
        messageType: 'TEXT',
        timestamp: DateTime.now(),
      );

      await _sendMessageUseCase.call(params: message);
    } catch (e) {
      // Handle error (maybe show snackbar)
    }
  }

  @override
  Future<void> close() {
    _messagesSubscription?.cancel();
    return super.close();
  }
}
