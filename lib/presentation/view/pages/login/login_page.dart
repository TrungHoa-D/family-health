import 'dart:ui';

import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:family_health/gen/assets.gen.dart';
import 'package:family_health/presentation/cubit_base/base_cubit_page.dart';
import 'package:family_health/presentation/resources/app_spacing.dart';
import 'package:family_health/presentation/resources/colors.dart';
import 'package:family_health/presentation/resources/styles.dart';
import 'package:family_health/presentation/resources/theme_data.dart';
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
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl, vertical: AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: AppSpacing.md),

                  // Header
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
                    'login.title'.tr(),
                    style: AppStyles.titleXLarge.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xxl),

                  // Illustration (Family Hero Image)
                  Expanded(
                    child: Center(
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 320),
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(48),
                            child: Image.asset(
                              'assets/images/illustration_family.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.xxl),

                  // Messaging
                  Text(
                    'login.welcome'.tr(),
                    style: AppStyles.displayLarge.copyWith(
                      color: AppColors.textPrimary,
                      fontSize: 28,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                    child: Text(
                      'login.description'.tr(),
                      style: AppStyles.bodyLarge.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 48),

                  // Google Login Button
                  _buildGoogleSignInButton(context, themeOwn),

                  const SizedBox(height: AppSpacing.xl),

                  // Disclaimer Text Setup
                  _buildDisclaimer(),

                  const SizedBox(height: AppSpacing.sm),
                ],
              ),
            ),
          ),
        ],
      ),
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
      buildWhen: (prev, curr) => prev.isSigningIn != curr.isSigningIn,
      builder: (context, state) {
        return SizedBox(
          width: double.infinity,
          height: 56, // Large button per design
          child: OutlinedButton(
            onPressed: state.isSigningIn
                ? null
                : () {
                    context.read<LoginCubit>().signInWithGoogle(context);
                  },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.border, width: 1.0),
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(100), // Fully rounded like the mockup
              ),
              backgroundColor: AppColors.white,
              elevation: 0,
            ),
            child: state.isSigningIn
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
                // TODO: Navigate to Terms of Use URL/Screen
              },
          ),
        ],
      ),
    );
  }
}
