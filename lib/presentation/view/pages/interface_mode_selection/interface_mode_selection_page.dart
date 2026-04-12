import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:family_health/presentation/cubit_base/base_cubit_page.dart';
import 'package:family_health/presentation/resources/app_spacing.dart';
import 'package:family_health/presentation/resources/colors.dart';
import 'package:family_health/presentation/resources/styles.dart';
import 'package:family_health/presentation/router/router.dart';
import 'package:family_health/presentation/view/widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'interface_mode_selection_cubit.dart';

@RoutePage()
class InterfaceModeSelectionPage extends BaseCubitPage<
    InterfaceModeSelectionCubit, InterfaceModeSelectionState> {
  const InterfaceModeSelectionPage({super.key});

  @override
  void onInitState(BuildContext context) {
    super.onInitState(context);
    context.read<InterfaceModeSelectionCubit>().init();
  }

  @override
  Widget builder(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primary),
          onPressed: () => context.router.maybePop(),
        ),
        title: Text(
          'interface_mode.title'.tr(),
          style: AppStyles.titleLarge.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'interface_mode.choose'.tr(),
                      style: AppStyles.displayLarge.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'interface_mode.choose_desc'.tr(),
                      style: AppStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    _buildOptions(context),
                  ],
                ),
              ),
            ),
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildOptions(BuildContext context) {
    return BlocBuilder<InterfaceModeSelectionCubit,
        InterfaceModeSelectionState>(
      builder: (context, state) {
        return Column(
          children: [
            _buildModeCard(
              context,
              mode: InterfaceMode.standard,
              isSelected: state.selectedMode == InterfaceMode.standard,
              icon: Icons.smartphone,
              title: 'interface_mode.standard'.tr(),
              desc: 'interface_mode.standard_desc'.tr(),
            ),
            const SizedBox(height: AppSpacing.lg),
            _buildModeCard(
              context,
              mode: InterfaceMode.simplified,
              isSelected: state.selectedMode == InterfaceMode.simplified,
              icon: Icons.elderly,
              title: 'interface_mode.simplified'.tr(),
              desc: 'interface_mode.simplified_desc'.tr(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildModeCard(
    BuildContext context, {
    required InterfaceMode mode,
    required bool isSelected,
    required IconData icon,
    required String title,
    required String desc,
  }) {
    return GestureDetector(
      onTap: () => context.read<InterfaceModeSelectionCubit>().selectMode(mode),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.05)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isSelected
                ? AppColors.primary
                : AppColors.border.withValues(alpha: 0.5),
            width: 2,
          ),
          boxShadow: [
            if (!isSelected)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.background,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  if (isSelected)
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                ],
              ),
              child: Icon(
                icon,
                color: isSelected ? AppColors.white : AppColors.textPrimary,
                size: 28,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppStyles.titleMedium.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    desc,
                    style: AppStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            if (isSelected)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
                child:
                    const Icon(Icons.check, color: AppColors.white, size: 16),
              )
            else
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.border, width: 2),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: AppButton.primary(
        title: 'interface_mode.continue'.tr(),
        onPressed: () async {
          final cubit = context.read<InterfaceModeSelectionCubit>();
          final success = await cubit.submitForm();
          if (success) {
            context.router.replaceAll([const HomeRoute()]);
          }
        },
        icon: const Icon(Icons.arrow_forward, color: AppColors.white),
      ),
    );
  }
}
