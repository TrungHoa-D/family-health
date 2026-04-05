import 'package:family_health/presentation/base/page_status.dart';
import 'package:family_health/presentation/cubit_base/base_cubit_state.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'family_group_state.freezed.dart';

enum FamilyGroupOption { create, join }

@freezed
class FamilyGroupState with _$FamilyGroupState implements BaseCubitState {
  const factory FamilyGroupState({
    @Default(PageStatus.Uninitialized) PageStatus pageStatus,
    String? pageErrorMessage,
    @Default(FamilyGroupOption.create) FamilyGroupOption selectedOption,
    @Default('') String groupName,
    @Default('') String inviteCode,
    @Default(false) bool isSubmitted,
    String? inviteCodeError,
  }) = _FamilyGroupState;

  const FamilyGroupState._();

  bool get isFormValid {
    if (selectedOption == FamilyGroupOption.create) {
      return groupName.isNotEmpty;
    } else {
      return inviteCode.length == 6;
    }
  }

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
