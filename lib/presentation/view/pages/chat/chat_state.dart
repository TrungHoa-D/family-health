import 'package:family_health/presentation/base/page_status.dart';
import 'package:family_health/presentation/cubit_base/base_cubit_state.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_state.freezed.dart';

enum MessageSenderType {
  me,
  otherMember,
  systemAi,
}

class ChatMessageModel {
  const ChatMessageModel({
    required this.id,
    required this.content,
    required this.time,
    required this.senderType,
    this.senderName,
    this.avatarUrl,
  });
  final String id;
  final String content;
  final DateTime time;
  final MessageSenderType senderType;
  final String? senderName;
  final String? avatarUrl;
}

@freezed
class ChatState with _$ChatState implements BaseCubitState {
  const factory ChatState({
    @Default(PageStatus.Uninitialized) PageStatus pageStatus,
    String? pageErrorMessage,
    @Default([]) List<ChatMessageModel> messages,
    @Default(3) int onlineMembers,
  }) = _ChatState;

  const ChatState._();

  @override
  BaseCubitState copyWithState({
    PageStatus? pageStatus,
    String? pageErrorMessage,
  }) {
    return copyWith(
      pageStatus: pageStatus ?? this.pageStatus,
      pageErrorMessage: pageErrorMessage ?? this.pageErrorMessage,
    );
  }
}
