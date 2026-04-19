import 'dart:io';
import 'dart:ui';

import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:family_health/gen/assets.gen.dart';
import 'package:family_health/presentation/cubit_base/base_cubit_page.dart';
import 'package:family_health/presentation/resources/app_spacing.dart';
import 'package:family_health/presentation/resources/colors.dart';
import 'package:family_health/presentation/resources/styles.dart';
import 'package:family_health/presentation/resources/theme_data.dart';
import 'package:family_health/presentation/view/widgets/app_button.dart';
import 'package:family_health/presentation/view/widgets/app_form_field.dart';
import 'package:family_health/shared/extension/theme_data.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'login_cubit.dart';

@RoutePage()
class LoginPage extends BaseCubitPage<LoginCubit, LoginState> {
  const LoginPage({super.key});

  @override
  void onInitState(BuildContext context) {
    super.onInitState(context);
    context.read<LoginCubit>().init();
  }

  @override
  Widget builder(BuildContext context) {
    final themeOwn = Theme.of(context).own();

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(
        children: [
          _buildBackgroundEllipses(),
          SafeArea(
            child: _buildContent(context, themeOwn),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, AppThemeData themeOwn) {
    final bool isWindows = Platform.isWindows;

    return BlocBuilder<LoginCubit, LoginState>(
      buildWhen: (prev, curr) => prev.isLoginMode != curr.isLoginMode,
      builder: (context, state) {
        return LayoutBuilder(
          builder: (context, constraints) {
            return ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight,
              ),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xl,
                    vertical: AppSpacing.sm,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: AppSpacing.sm),
                      _buildHeader(state.isLoginMode),
                      const SizedBox(height: AppSpacing.xs),
                      Center(
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 160),
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(40),
                              child: Image.asset(
                                'assets/images/illustration_family.png',
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      _buildWelcomeText(),
                      const SizedBox(height: AppSpacing.md),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 380),
                        child:
                            _buildEmailPasswordForm(context, state.isLoginMode),
                      ),
                      if (!isWindows) ...[
                        const SizedBox(height: AppSpacing.md),
                        _buildOrDivider(),
                        const SizedBox(height: AppSpacing.md),
                        ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 380),
                          child: _buildGoogleSignInButton(context, themeOwn),
                        ),
                      ],
                      const SizedBox(height: AppSpacing.lg),
                      _buildDisclaimer(),
                      const SizedBox(height: AppSpacing.xs),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEmailPasswordForm(BuildContext context, bool isLoginMode) {
    return BlocBuilder<LoginCubit, LoginState>(
      buildWhen: (prev, curr) =>
          prev.isSigningInEmail != curr.isSigningInEmail ||
          prev.isPasswordVisible != curr.isPasswordVisible ||
          prev.emailError != curr.emailError ||
          prev.passwordError != curr.passwordError,
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'login.email_label'.tr(),
              style: AppStyles.labelMedium.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),

            // Email field
            AppFormField(
              hintText: 'login.email_hint'.tr(),
              keyboardType: TextInputType.emailAddress,
              errorText: state.emailError,
              onChanged: (v) => context.read<LoginCubit>().onEmailChanged(v),
            ),

            const SizedBox(height: AppSpacing.md),

            // Password label
            Text(
              'login.password_label'.tr(),
              style: AppStyles.labelMedium.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),

            // Password field — dùng decoration để thêm suffixIcon
            AppFormField(
              hintText: 'login.password_hint'.tr(),
              obscureText: !state.isPasswordVisible,
              errorText: state.passwordError,
              onChanged: (v) => context.read<LoginCubit>().onPasswordChanged(v),
              decoration: InputDecoration(
                suffixIcon: IconButton(
                  icon: Icon(
                    state.isPasswordVisible
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                  onPressed: () =>
                      context.read<LoginCubit>().togglePasswordVisibility(),
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Sign In / Sign Up button
            AppButton.primary(
              title: isLoginMode
                  ? 'login.sign_in_email'.tr()
                  : 'login.sign_up_email'.tr(),
              enable: !state.isSigningInEmail,
              onPressed: () =>
                  context.read<LoginCubit>().submitEmailForm(context),
              icon: state.isSigningInEmail
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.white,
                      ),
                    )
                  : null,
            ),

            const SizedBox(height: AppSpacing.md),

            // Toggle login/signup mode
            Center(
              child: TextButton(
                onPressed: state.isSigningInEmail
                    ? null
                    : () => context.read<LoginCubit>().toggleLoginMode(),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                ),
                child: Text(
                  isLoginMode
                      ? 'login.toggle_to_sign_up'.tr()
                      : 'login.toggle_to_sign_in'.tr(),
                  style: AppStyles.labelMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ─── Shared Widgets ──────────────────────────────────────────────────────

  Widget _buildHeader(bool isLoginMode) {
    return Column(
      children: [
        Text(
          'FAMILY HEALTH',
          style: AppStyles.labelSmall.copyWith(
            color: AppColors.primary,
            fontWeight: FontWeight.w700,
            letterSpacing: 2.0,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          isLoginMode ? 'login.title'.tr() : 'login.sign_up_email'.tr(),
          style: AppStyles.titleXLarge.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildOrDivider() {
    return Row(
      children: [
        const Expanded(child: Divider()),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text(
            'login.or_divider'.tr(),
            style:
                AppStyles.labelSmall.copyWith(color: AppColors.textSecondary),
          ),
        ),
        const Expanded(child: Divider()),
      ],
    );
  }

  Widget _buildWelcomeText() {
    return Column(
      children: [
        Text(
          'login.welcome'.tr(),
          style: AppStyles.displayLarge.copyWith(
            color: AppColors.textPrimary,
            fontSize: 24, // reduced font size
            height: 1.2,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.sm),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text(
            'login.description'.tr(),
            style: AppStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildBackgroundEllipses() {
    return Stack(
      children: [
        Positioned(
          left: -40,
          top: -40,
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withValues(alpha: 0.1),
            ),
          ),
        ),
        Positioned(
          right: -40,
          bottom: -40,
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF68FADD).withValues(alpha: 0.1),
            ),
          ),
        ),
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
            child: Container(color: Colors.transparent),
          ),
        ),
      ],
    );
  }

  Widget _buildGoogleSignInButton(BuildContext context, AppThemeData themeOwn) {
    return BlocBuilder<LoginCubit, LoginState>(
      buildWhen: (prev, curr) => prev.isSigningInGoogle != curr.isSigningInGoogle,
      builder: (context, state) {
        return SizedBox(
          width: double.infinity,
          height: 56,
          child: OutlinedButton(
            onPressed: state.isSigningInGoogle
                ? null
                : () {
                    context.read<LoginCubit>().signInWithGoogle(context);
                  },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.border, width: 1.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(100),
              ),
              backgroundColor: AppColors.white,
              elevation: 0,
            ),
            child: state.isSigningInGoogle
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: themeOwn.colorSchema?.primary ?? AppColors.primary,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Assets.icons.icGoogle.svg(width: 24, height: 24),
                      const SizedBox(width: AppSpacing.sm),
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'login.sign_in_google'.tr(),
                            style: AppStyles.titleMedium.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }

  Widget _buildDisclaimer() {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        style: AppStyles.labelMedium.copyWith(
          color: AppColors.textSecondary,
          height: 1.5,
        ),
        children: [
          TextSpan(text: 'login.disclaimer'.tr()),
          TextSpan(
            text: 'login.terms'.tr(),
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                // TODO(TrungHoa): Navigate to Terms of Use URL/Screen
              },
          ),
        ],
      ),
    );
  }
}
