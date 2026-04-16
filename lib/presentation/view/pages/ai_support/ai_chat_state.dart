part of 'ai_chat_cubit.dart';

@freezed
class AIChatSupportState with _$AIChatSupportState implements BaseCubitState {
  const factory AIChatSupportState({
    @Default(PageStatus.Uninitialized) PageStatus pageStatus,
    String? pageErrorMessage,
    @Default([]) List<AIChatMessage> messages,
    @Default(false) bool isTyping,
    String? userId,
    HealthProfile? healthProfile,
  }) = _AIChatSupportState;

  const AIChatSupportState._();

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
