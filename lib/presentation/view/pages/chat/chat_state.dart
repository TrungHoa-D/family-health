import 'package:family_health/domain/entities/chat_message.dart';
import 'package:family_health/presentation/base/page_status.dart';
import 'package:family_health/presentation/cubit_base/base_cubit_state.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'chat_state.freezed.dart';

@freezed
class ChatState with _$ChatState implements BaseCubitState {
  const factory ChatState({
    @Default(PageStatus.Uninitialized) PageStatus pageStatus,
    String? pageErrorMessage,
    @Default([]) List<ChatMessage> messages,
    @Default(3) int onlineMembers,
    @Default(true) bool hasFamilyGroup,
    String? currentFamilyId,
    String? currentUserId,
    String? familyGroupName,
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
