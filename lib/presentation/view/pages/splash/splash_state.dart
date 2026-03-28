part of 'splash_cubit.dart';

@freezed
class SplashState with _$SplashState implements BaseCubitState {
  const factory SplashState({
    @Default(PageStatus.Loaded) PageStatus pageStatus,
    String? pageErrorMessage,
    @Default(false) bool isCheckingAuth,
    @Default(false) bool isAuthenticated,
  }) = _SplashState;

  const SplashState._();

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
