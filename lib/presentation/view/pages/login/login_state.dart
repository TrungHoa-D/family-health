part of 'login_cubit.dart';

@freezed
class LoginState with _$LoginState implements BaseCubitState {
  const factory LoginState({
    @Default(PageStatus.Uninitialized) PageStatus pageStatus,
    String? pageErrorMessage,
    @Default(false) bool isSigningIn,
    UserEntity? user,
    @Default(true) bool isLoginMode,
    // Email/Password form fields (for Windows desktop)
    @Default('') String email,
    @Default('') String password,
    @Default(false) bool isPasswordVisible,
    String? emailError,
    String? passwordError,
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
