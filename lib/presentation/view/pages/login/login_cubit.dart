import 'package:auto_route/auto_route.dart';
import 'package:family_health/domain/entities/user_entity.dart';
import 'package:family_health/domain/usecases/google_sign_in_usecase.dart';
import 'package:family_health/presentation/base/page_status.dart';
import 'package:family_health/presentation/cubit_base/base_cubit.dart';
import 'package:family_health/presentation/cubit_base/base_cubit_state.dart';
import 'package:family_health/presentation/router/router.dart';
import 'package:family_health/shared/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

part 'login_cubit.freezed.dart';
part 'login_state.dart';

@injectable
class LoginCubit extends BaseCubit<LoginState> {
  LoginCubit(this._googleSignInUseCase) : super(const LoginState());

  final GoogleSignInUseCase _googleSignInUseCase;

  Future<void> init() async {
    emit(state.copyWith(pageStatus: PageStatus.Loaded));
  }

  Future<void> signInWithGoogle(BuildContext context) async {
    emit(state.copyWith(isSigningIn: true));
    try {
      final UserEntity user =
          await _googleSignInUseCase.call(params: null);
      emit(state.copyWith(isSigningIn: false, user: user));

      if (context.mounted) {
        // Tạm thời luôn trả về true để test (coi như chưa có hồ sơ sức khỏe)
        // ignore: dead_code
        const bool isMissingHealthProfile = true;
        if (isMissingHealthProfile) {
          context.router.replaceAll([const SetupHealthProfileRoute()]);
        } else {
          context.router.replaceAll([const HomeRoute()]);
        }
      }
    } catch (e) {
      logger.e('Google Sign-In failed: $e');
      emit(state.copyWith(isSigningIn: false));
      showErrorDialog('Google Sign-In failed. Please try again.');
    }
  }
}

