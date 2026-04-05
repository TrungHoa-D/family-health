part of 'profile_edit_cubit.dart';

@freezed
class ProfileEditState with _$ProfileEditState implements BaseCubitState {
  const factory ProfileEditState({
    @Default(PageStatus.Uninitialized) PageStatus pageStatus,
    String? pageErrorMessage,
    @Default('') String name,
    @Default('') String phoneNumber,
    File? avatarFile,
    @Default(false) bool isSuccess,
  }) = _ProfileEditState;

  const ProfileEditState._();

  @override
  BaseCubitState copyWithState({
    PageStatus? pageStatus,
    String? pageErrorMessage,
  }) {
    return copyWith(
      pageStatus: pageStatus ?? this.pageStatus,
      pageErrorMessage: pageErrorMessage,
      name: name,
      phoneNumber: phoneNumber,
      isSuccess: isSuccess,
    );
  }
}
