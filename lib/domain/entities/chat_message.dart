import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_message.freezed.dart';
part 'chat_message.g.dart';

enum MessageType {
  TEXT,
  IMAGE,
  QUICK_REPLY,
}

@freezed
class ChatMessage with _$ChatMessage {
  const factory ChatMessage({
    required String id,
    required String senderId,
    required String familyId,
    required String content,
    required DateTime timestamp,
    @Default(MessageType.TEXT) MessageType type,
    @Default([]) List<String> readBy,
  }) = _ChatMessage;

  factory ChatMessage.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageFromJson(json);
}
