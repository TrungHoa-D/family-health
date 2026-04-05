part of 'ai_chat_cubit.dart';

@freezed
class AIChatState with _$AIChatState implements BaseCubitState {
  const factory AIChatState({
    @Default(PageStatus.Uninitialized) PageStatus pageStatus,
    String? pageErrorMessage,
    @Default('') String medicationName,
    @Default([]) List<ChatMessage> messages,
    @Default(false) bool isTyping,
  }) = _AIChatState;

  const AIChatState._();

  @override
  BaseCubitState copyWithState({
    PageStatus? pageStatus,
    String? pageErrorMessage,
  }) {
    return copyWith(
      pageStatus: pageStatus ?? this.pageStatus,
      pageErrorMessage: pageErrorMessage,
    );
  }
}
