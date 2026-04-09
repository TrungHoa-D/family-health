import 'package:family_health/shared/utils/timestamp_converter.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'ai_chat_message.freezed.dart';
part 'ai_chat_message.g.dart';

@freezed
class AIChatMessage with _$AIChatMessage {
  const factory AIChatMessage({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    required String role, // user or assistant
    required String content,
    @TimestampConverter() required DateTime timestamp,
  }) = _AIChatMessage;

  factory AIChatMessage.fromJson(Map<String, dynamic> json) =>
      _$AIChatMessageFromJson(json);
}
