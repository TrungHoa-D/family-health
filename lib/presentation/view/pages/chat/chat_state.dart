import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_state.freezed.dart';

enum MessageSenderType {
  me,
  otherMember,
  systemAi,
}

class ChatMessageModel {
  final String id;
  final String content;
  final DateTime time;
  final MessageSenderType senderType;
  final String? senderName;
  final String? avatarUrl; // Initials placeholder

  const ChatMessageModel({
    required this.id,
    required this.content,
    required this.time,
    required this.senderType,
    this.senderName,
    this.avatarUrl,
  });
}

@freezed
class ChatState with _$ChatState {
  const factory ChatState({
    @Default([]) List<ChatMessageModel> messages,
    @Default(3) int onlineMembers,
  }) = _ChatState;
}
