part of 'family_management_cubit.dart';

@freezed
class FamilyManagementState
    with _$FamilyManagementState
    implements BaseCubitState {
  const factory FamilyManagementState({
    @Default(PageStatus.Uninitialized) PageStatus pageStatus,
    String? pageErrorMessage,
    FamilyGroup? family,
    @Default([]) List<UserEntity> members,
    @Default(false) bool isAdmin,
    @Default(false) bool isLeaved,
  }) = _FamilyManagementState;

  const FamilyManagementState._();

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
