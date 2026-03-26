import 'package:auto_route/auto_route.dart';
import 'package:family_health/presentation/cubit_base/base_cubit_page.dart';
import 'package:family_health/presentation/resources/app_spacing.dart';
import 'package:family_health/presentation/resources/colors.dart';
import 'package:family_health/presentation/resources/styles.dart';
import 'package:family_health/presentation/view/widgets/app_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';

import 'splash_cubit.dart';

@RoutePage()
class SplashPage extends BaseCubitPage<SplashCubit, SplashState> {
  const SplashPage({super.key});

  @override
  void onInitState(BuildContext context) {
    super.onInitState(context);
    context.read<SplashCubit>().init(context);
  }

  @override
  Widget builder(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primary, // Darker blue at top
              AppColors.primaryLight, // Lighter blue at bottom
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),

              // App Logo Card
              const AppCard(
                borderRadius: 24,
                enableShadow: true,
                child: SizedBox(
                  width: 72,
                  height: 72,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Icon(
                        Icons.favorite,
                        color: AppColors.primary,
                        size: 48,
                      ),
                      Icon(
                        Icons.add,
                        color: AppColors.white,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppSpacing.lg),

              // App Title
              Text(
                'splash.title'.tr(),
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: AppColors.white,
                  height: 1.2,
                ),
              ),

              const SizedBox(height: AppSpacing.sm),

              // App Subtitle
              Text(
                'splash.subtitle'.tr(),
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                  color: AppColors.white,
                  height: 1.4,
                ),
              ),

              const Spacer(),

              // Bottom Section
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'splash.footer'.tr(),
                    style: AppStyles.labelSmall.copyWith(
                      color: AppColors.white.withValues(alpha: 0.7),
                      letterSpacing: 2.0,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                    strokeWidth: 3,
                  ),
                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
