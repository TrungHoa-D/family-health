import 'dart:ui';

import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:family_health/gen/assets.gen.dart';
import 'package:family_health/presentation/cubit_base/base_cubit_page.dart';
import 'package:family_health/presentation/resources/colors.dart';
import 'package:family_health/presentation/resources/theme_data.dart';
import 'package:family_health/shared/extension/theme_data.dart';

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
      body: Stack(
        children: [
          _buildBackgroundEllipses(),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                height: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
                child: Column(
                  children: [
                    const SizedBox(height: 32),
                    _buildLogo(),
                    const Spacer(flex: 2),
                    _buildHeadline(themeOwn),
                    const SizedBox(height: 32),
                    _buildGoogleSignInButton(context, themeOwn),
                    const Spacer(flex: 3),
                  ],
                ),
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
          left: -233,
          top: -44,
          child: Container(
            width: 357,
            height: 357,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.loginEllipse1,
            ),
          ),
        ),
        Positioned(
          right: -189,
          top: 90,
          child: Container(
            width: 357,
            height: 357,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.loginEllipse2,
            ),
          ),
        ),
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 120, sigmaY: 120),
            child: Container(color: Colors.transparent),
          ),
        ),
      ],
    );
  }

  Widget _buildLogo() {
    return Center(
      child: Image.asset(
        'assets/images/logo.png',
        width: 128,
        height: 128,
      ),
    );
  }

  Widget _buildHeadline(AppThemeData themeOwn) {
    return Column(
      spacing: 12,
      children: [
        ShaderMask(
          shaderCallback: (Rect bounds) {
            return const LinearGradient(
              colors: [
                AppColors.loginGradient1,
                AppColors.loginGradient2,
                AppColors.loginGradient3,
              ],
            ).createShader(bounds);
          },
          child: Text(
            'login.get_started'.tr(),
            style: themeOwn.textTheme?.h2?.copyWith(
              fontSize: 26,
              letterSpacing: -0.52,
              color: AppColors.white,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        Text(
          'login.subtitle'.tr(),
          style: themeOwn.textTheme?.small?.copyWith(
            color: AppColors.loginSubtitle,
            letterSpacing: -0.12,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildGoogleSignInButton(
    BuildContext context,
    AppThemeData themeOwn,
  ) {
    return BlocBuilder<LoginCubit, LoginState>(
      buildWhen: (prev, curr) => prev.isSigningIn != curr.isSigningIn,
      builder: (context, state) {
        return SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton(
            onPressed: state.isSigningIn
                ? null
                : () {
                    context.read<LoginCubit>().signInWithGoogle(context);
                  },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.loginButtonBorder),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
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
                      color: themeOwn.colorSchema?.primary,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 10,
                    children: [
                      Assets.icons.icGoogle.svg(width: 18, height: 18),
                      Text(
                        'login.sign_in_google'.tr(),
                        style: themeOwn.textTheme?.highlightsBold?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.loginCardText,
                          letterSpacing: -0.14,
                        ),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}
