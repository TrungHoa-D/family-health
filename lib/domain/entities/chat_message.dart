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
    @JsonKey(name: 'family_id') required String familyId,
    @JsonKey(name: 'sender_id') required String senderId,
    @JsonKey(name: 'sender_name') required String senderName,
    @JsonKey(name: 'sender_avatar_url') String? senderAvatarUrl,
    required String content,
    @JsonKey(name: 'message_type') required String messageType,
    required DateTime timestamp,
    @Default([]) List<String> readBy,
    @JsonKey(name: 'images_url') @Default([]) List<String> imageUrls,
  }) = _ChatMessage;

  factory ChatMessage.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageFromJson(json);
}
