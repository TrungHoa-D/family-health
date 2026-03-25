part of 'login_cubit.dart';

@freezed
class LoginState with _$LoginState implements BaseCubitState {
  const factory LoginState({
    @Default(PageStatus.Uninitialized) PageStatus pageStatus,
    String? pageErrorMessage,
    @Default(false) bool isSigningIn,
    UserEntity? user,
  }) = _LoginState;

  const LoginState._();

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
