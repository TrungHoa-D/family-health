import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:family_health/domain/entities/user_entity.dart';
import 'package:family_health/domain/usecases/email_sign_in_usecase.dart';
import 'package:family_health/domain/usecases/email_sign_up_usecase.dart';
import 'package:family_health/domain/usecases/get_user_usecase.dart';
import 'package:family_health/domain/usecases/google_sign_in_usecase.dart';
import 'package:family_health/domain/usecases/sync_user_usecase.dart';
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
  LoginCubit(
    this._googleSignInUseCase,
    this._emailSignInUseCase,
    this._emailSignUpUseCase,
    this._syncUserUseCase,
    this._getUserUseCase,
  ) : super(const LoginState());

  final GoogleSignInUseCase _googleSignInUseCase;
  final EmailSignInUseCase _emailSignInUseCase;
  final EmailSignUpUseCase _emailSignUpUseCase;
  final SyncUserUseCase _syncUserUseCase;
  final GetUserUseCase _getUserUseCase;

  Future<void> init() async {
    emit(state.copyWith(pageStatus: PageStatus.Loaded));
  }

  // ── Email/Password form handlers (Windows) ──────────────────────────────

  void onEmailChanged(String value) {
    emit(state.copyWith(email: value, emailError: null));
  }

  void onPasswordChanged(String value) {
    emit(state.copyWith(password: value, passwordError: null));
  }

  void togglePasswordVisibility() {
    emit(state.copyWith(isPasswordVisible: !state.isPasswordVisible));
  }

  void toggleLoginMode() {
    emit(
      state.copyWith(
        isLoginMode: !state.isLoginMode,
        emailError: null,
        passwordError: null,
      ),
    );
  }

  bool _validateEmailForm() {
    String? emailError;
    String? passwordError;

    if (state.email.trim().isEmpty) {
      emailError = 'login.email_required'.tr();
    }
    if (state.password.isEmpty) {
      passwordError = 'login.password_required'.tr();
    }

    if (emailError != null || passwordError != null) {
      emit(
        state.copyWith(
          emailError: emailError,
          passwordError: passwordError,
        ),
      );
      return false;
    }
    return true;
  }

  Future<void> submitEmailForm(BuildContext context) async {
    if (!_validateEmailForm()) {
      return;
    }

    emit(state.copyWith(isSigningInEmail: true));
    try {
      final params = EmailSignInParams(
        email: state.email.trim(),
        password: state.password,
      );

      final UserEntity user;
      if (state.isLoginMode) {
        user = await _emailSignInUseCase.call(params: params);
      } else {
        user = await _emailSignUpUseCase.call(params: params);
      }

      final existingUser = await _getUserUseCase.call(params: user.uid);
      
      if (existingUser == null) {
        // Người dùng mới: Đồng bộ dữ liệu cơ bản và bắt đầu onboarding
        await _syncUserUseCase.call(params: user);
        emit(state.copyWith(isSigningInEmail: false, user: user));
        if (context.mounted) {
          context.router.replaceAll([const InterfaceModeSelectionRoute()]);
        }
      } else {
        // Người dùng cũ: Sử dụng dữ liệu từ Firestore, tránh ghi đè dữ liệu quan trọng
        emit(state.copyWith(isSigningInEmail: false, user: existingUser));
        if (context.mounted) {
          // Kiểm tra xem đã cài đặt chế độ giao diện chưa
          if (existingUser.uiPreference == null) {
            context.router.replaceAll([const InterfaceModeSelectionRoute()]);
          } else {
            // HomeRoute sẽ có FamilyGuard để kiểm tra tiếp family_id
            context.router.replaceAll([const HomeRoute()]);
          }
        }
      }

    } catch (e) {
      logger.e('Email Form failed: $e');
      emit(state.copyWith(isSigningInEmail: false));
      if (state.isLoginMode) {
        showErrorDialog('login.sign_in_failed'.tr());
      } else {
        showErrorDialog('login.sign_up_failed'.tr());
      }
    }
  }

  // ── Google Sign-In (Android / iOS) ──────────────────────────────────────

  Future<void> signInWithGoogle(BuildContext context) async {
    emit(state.copyWith(isSigningInGoogle: true));
    try {
      final UserEntity user = await _googleSignInUseCase.call(params: null);

      final existingUser = await _getUserUseCase.call(params: user.uid);
      
      if (existingUser == null) {
        // Người dùng mới: Đồng bộ dữ liệu cơ bản và bắt đầu onboarding
        await _syncUserUseCase.call(params: user);
        emit(state.copyWith(isSigningInGoogle: false, user: user));
        if (context.mounted) {
          context.router.replaceAll([const InterfaceModeSelectionRoute()]);
        }
      } else {
        // Người dùng cũ: Sử dụng dữ liệu từ Firestore, tránh ghi đè
        emit(state.copyWith(isSigningInGoogle: false, user: existingUser));
        if (context.mounted) {
          if (existingUser.uiPreference == null) {
            context.router.replaceAll([const InterfaceModeSelectionRoute()]);
          } else {
            context.router.replaceAll([const HomeRoute()]);
          }
        }
      }
    } catch (e) {
      logger.e('Google Sign-In failed: $e');
      emit(state.copyWith(isSigningInGoogle: false));
      showErrorDialog('Google Sign-In failed. Please try again.');
    }
  }
}
