part of 'global_auth_cubit.dart';

@freezed
class GlobalAuthState with _$GlobalAuthState implements BaseCubitState {
  const factory GlobalAuthState({
    @Default(PageStatus.Loaded) PageStatus pageStatus,
    String? pageErrorMessage,
    @Default(SessionStatus.unauthenticated) SessionStatus sessionStatus,
  }) = _GlobalAuthState;

  const GlobalAuthState._();

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

enum SessionStatus {
  authenticated,
  unauthenticated, // Default or logged out
  expired, // Show dialog "Session Expired"
  loggedOut, // Redirect to Login
}
