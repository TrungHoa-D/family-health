import 'dart:async';
import 'dart:io';

import 'package:family_health/domain/entities/chat_message.dart';
import 'package:family_health/domain/usecases/fetch_family_usecase.dart';
import 'package:family_health/domain/usecases/get_user_usecase.dart';
import 'package:family_health/domain/usecases/send_message_usecase.dart';
import 'package:family_health/domain/usecases/upload_chat_images_usecase.dart';
import 'package:family_health/domain/usecases/delete_message_usecase.dart';
import 'package:family_health/domain/usecases/edit_message_usecase.dart';
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
    this._getUserUseCase,
    this._fetchFamilyUseCase,
    this._uploadChatImagesUseCase,
    this._deleteMessageUseCase,
    this._editMessageUseCase, {
    FirebaseAuth? firebaseAuth,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        super(const ChatState()) {
    _init();
  }

  final WatchChatMessagesUseCase _watchChatMessagesUseCase;
  final SendMessageUseCase _sendMessageUseCase;
  final GetUserUseCase _getUserUseCase;
  final FetchFamilyUseCase _fetchFamilyUseCase;
  final UploadChatImagesUseCase _uploadChatImagesUseCase;
  final DeleteMessageUseCase _deleteMessageUseCase;
  final EditMessageUseCase _editMessageUseCase;
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

      final familyGroup = await _fetchFamilyUseCase.call(params: familyId);

      emit(state.copyWith(
        currentFamilyId: familyId,
        currentUserId: user.uid,
        hasFamilyGroup: true,
        familyGroupName: familyGroup?.familyName,
      ));

      _messagesSubscription?.cancel();
      final messageStream = await _watchChatMessagesUseCase.call(params: familyId);
      _messagesSubscription = messageStream.listen((messages) {
        if (isClosed) return;
        final sortedMessages = List<ChatMessage>.from(messages)
          ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

        emit(state.copyWith(
          messages: sortedMessages,
          pageStatus: PageStatus.Loaded,
        ));
      }, onError: (e) {
        if (isClosed) return;
        emit(state.copyWith(
          pageStatus: PageStatus.Error,
          pageErrorMessage: 'Có lỗi xảy ra, có thể đang thiếu Index trên Firestore.',
        ));
      });
    } catch (e) {
      emit(state.copyWith(
        pageStatus: PageStatus.Error,
        pageErrorMessage: e.toString(),
      ));
    }
  }

  Future<void> sendMessage(String text, {List<File> images = const []}) async {
    final hasText = text.trim().isNotEmpty;
    final hasImages = images.isNotEmpty;

    if (!hasText && !hasImages) return;
    if (state.currentFamilyId == null || state.currentUserId == null) return;

    try {
      List<String> imageUrls = [];

      // Upload images if any
      if (hasImages) {
        emit(state.copyWith(isSendingImage: true));
        imageUrls = await _uploadChatImagesUseCase.call(
          params: UploadChatImagesParams(
            familyId: state.currentFamilyId!,
            files: images,
          ),
        );
      }

      final userEntity = await _getUserUseCase.call(params: state.currentUserId!);

      final messageType = hasImages ? 'IMAGE' : 'TEXT';

      final message = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        familyId: state.currentFamilyId!,
        senderId: state.currentUserId!,
        senderName: userEntity?.displayName ?? 'Thành viên',
        senderAvatarUrl: userEntity?.avatarUrl,
        content: text,
        messageType: messageType,
        timestamp: DateTime.now(),
        imageUrls: imageUrls,
      );

      await _sendMessageUseCase.call(params: message);
    } catch (e) {
      // Handle error (maybe show snackbar)
    } finally {
      if (!isClosed) {
        emit(state.copyWith(isSendingImage: false));
      }
    }
  }

  Future<void> deleteMessage(String id) async {
    try {
      await _deleteMessageUseCase.call(params: id);
    } catch (e) {
      emit(state.copyWith(
        pageErrorMessage: 'Lỗi khi xóa tin nhắn: $e',
      ));
    }
  }

  Future<void> editMessage(String id, String newContent) async {
    try {
      await _editMessageUseCase.call(
        params: EditMessageParams(id: id, newContent: newContent),
      );
    } catch (e) {
      emit(state.copyWith(
        pageErrorMessage: 'Lỗi khi sửa tin nhắn: $e',
      ));
    }
  }

  @override
  Future<void> close() {
    _messagesSubscription?.cancel();
    return super.close();
  }
}
