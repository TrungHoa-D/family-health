import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:family_health/presentation/cubit_base/base_cubit_page.dart';
import 'package:family_health/presentation/resources/app_spacing.dart';
import 'package:family_health/presentation/resources/colors.dart';
import 'package:family_health/presentation/resources/styles.dart';
import 'package:family_health/presentation/router/router.dart';
import 'package:family_health/presentation/view/widgets/app_button.dart';
import 'package:family_health/presentation/view/widgets/app_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'family_setup_cubit.dart';

@RoutePage()
class FamilySetupPage
    extends BaseCubitPage<FamilySetupCubit, FamilySetupState> {
  const FamilySetupPage({super.key});

  @override
  void onInitState(BuildContext context) {
    super.onInitState(context);
    context.read<FamilySetupCubit>().init();
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
          'family_setup.title'.tr(),
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
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: AppSpacing.lg),
                    _buildHeader(),
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

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.family_restroom,
            color: AppColors.primary,
            size: 32,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'family_setup.start_journey'.tr(),
          style: AppStyles.displayLarge.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w800,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'family_setup.journey_desc'.tr(),
          style: AppStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildOptions(BuildContext context) {
    return BlocBuilder<FamilySetupCubit, FamilySetupState>(
      builder: (context, state) {
        return Column(
          children: [
            _buildCreateFamilyCard(context, state),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: Row(
                children: [
                  Expanded(
                      child: Divider(
                          color: AppColors.border.withValues(alpha: 0.5))),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                    child: Text(
                      'family_setup.or'.tr().toUpperCase(),
                      style: AppStyles.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                  Expanded(
                      child: Divider(
                          color: AppColors.border.withValues(alpha: 0.5))),
                ],
              ),
            ),
            _buildJoinFamilyCard(context, state),
          ],
        );
      },
    );
  }

  Widget _buildCreateFamilyCard(BuildContext context, FamilySetupState state) {
    final isSelected = state.selectedOption == FamilySetupOption.create;
    return GestureDetector(
      onTap: () => context
          .read<FamilySetupCubit>()
          .selectOption(FamilySetupOption.create),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            if (!isSelected)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              )
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.groups, color: AppColors.success),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'family_setup.create_family'.tr(),
                    style: AppStyles.titleMedium.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'family_setup.create_family_desc'.tr(),
                    style: AppStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJoinFamilyCard(BuildContext context, FamilySetupState state) {
    final isSelected = state.selectedOption == FamilySetupOption.join;
    return GestureDetector(
      onTap: () =>
          context.read<FamilySetupCubit>().selectOption(FamilySetupOption.join),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.link, color: AppColors.primary),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'family_setup.join_family'.tr(),
                        style: AppStyles.titleMedium.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'family_setup.join_family_desc'.tr(),
                        style: AppStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (isSelected) ...[
              const SizedBox(height: AppSpacing.md),
              AppFormField(
                hintText: 'family_setup.invite_code_hint'.tr(),
                maxLength: 6,
                textCapitalization: TextCapitalization.characters,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9]')),
                ],
                onChanged: (val) =>
                    context.read<FamilySetupCubit>().updateInviteCode(val),
                errorText: state.inviteCodeError != null
                    ? (state.inviteCodeError == 'required'
                        ? 'error.field_is_required'.tr()
                        : 'Mã không hợp lệ')
                    : null,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'family_setup.invite_code_hint_desc'.tr(),
                style: AppStyles.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.background,
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppButton.primary(
            title: 'family_setup.continue'.tr(),
            onPressed: () {
              final cubit = context.read<FamilySetupCubit>();
              if (cubit.submitForm()) {
                context.router.push(const InterfaceModeSelectionRoute());
              }
            },
            icon: const Icon(Icons.arrow_forward, color: AppColors.white),
          ),
          const SizedBox(height: AppSpacing.md),
          GestureDetector(
            onTap: () {
              // Help action
            },
            child: Text(
              'family_setup.need_help'.tr(),
              style: AppStyles.labelMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          )
        ],
      ),
    );
  }
}
