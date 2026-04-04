import 'package:auto_route/auto_route.dart';
import 'package:family_health/domain/entities/user_entity.dart';
import 'package:family_health/domain/usecases/check_auth_status_usecase.dart';
import 'package:family_health/domain/usecases/get_user_usecase.dart';
import 'package:family_health/presentation/base/page_status.dart';
import 'package:family_health/presentation/cubit_base/base_cubit.dart';
import 'package:family_health/presentation/cubit_base/base_cubit_state.dart';
import 'package:family_health/presentation/router/router.dart';
import 'package:family_health/shared/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

part 'splash_cubit.freezed.dart';
part 'splash_state.dart';

@injectable
class SplashCubit extends BaseCubit<SplashState> {
  SplashCubit(this._checkAuthStatusUseCase, this._getUserUseCase)
      : super(const SplashState());

  final CheckAuthStatusUseCase _checkAuthStatusUseCase;
  final GetUserUseCase _getUserUseCase;

  Future<void> init(BuildContext context) async {
    emit(state.copyWith(pageStatus: PageStatus.Loaded, isCheckingAuth: true));

    // Delay at least 1.5 seconds for UX (to show the splash logo properly)
    final delayFuture = Future.delayed(const Duration(milliseconds: 1500));
    final authFuture = _checkAuthStatusUseCase.call(params: null);

    final List<dynamic> results = await Future.wait([delayFuture, authFuture]);
    final UserEntity? user = results[1] as UserEntity?;

    if (user != null) {
      final userData = await _getUserUseCase.call(params: user.uid);
      if (userData != null) {
        logger.i(
          'Fetched user data from Firestore: ${userData.displayName} / ${userData.email}',
        );
      } else {
        logger.i('User exists in Auth but not in Firestore yet.');
      }
    }

    emit(
      state.copyWith(
        pageStatus: PageStatus.Loaded,
        isCheckingAuth: false,
        isAuthenticated: user != null,
      ),
    );

    if (context.mounted) {
      if (user != null) {
        context.router.replaceAll([const HomeRoute()]);
      } else {
        context.router.replaceAll([const LoginRoute()]);
      }
    }
  }
}
