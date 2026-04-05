import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:family_health/presentation/base/page_status.dart';
import 'package:family_health/presentation/cubit_base/base_cubit_page.dart';
import 'package:family_health/presentation/resources/app_spacing.dart';
import 'package:family_health/presentation/resources/colors.dart';
import 'package:family_health/presentation/resources/styles.dart';
import 'package:family_health/presentation/router/router.dart';
import 'package:family_health/presentation/view/pages/family_group/family_group_cubit.dart';
import 'package:family_health/presentation/view/pages/family_group/family_group_state.dart';
import 'package:family_health/presentation/view/widgets/app_button.dart';
import 'package:family_health/presentation/view/widgets/app_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

@RoutePage()
class FamilyGroupPage
    extends BaseCubitPage<FamilyGroupCubit, FamilyGroupState> {
  const FamilyGroupPage({super.key});

  @override
  Widget pageLoadingBuilder(BuildContext context) {
    return builder(context);
  }

  @override
  void onInitState(BuildContext context) {
    super.onInitState(context);
    context.read<FamilyGroupCubit>().init();
  }

  @override
  Widget builder(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'family_group.title'.tr(),
          style: AppStyles.titleLarge.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: BlocConsumer<FamilyGroupCubit, FamilyGroupState>(
          listener: (context, state) {
            if (state.pageStatus == PageStatus.Success) {
              context.router.replaceAll([const HomeRoute()]);
            } else if (state.pageStatus == PageStatus.Error) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    state.pageErrorMessage ?? 'common.error_generic'.tr(),
                  ),
                  backgroundColor: AppColors.error,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          builder: (context, state) {
            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding:
                        const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                    child: Column(
                      children: [
                        const SizedBox(height: AppSpacing.lg),
                        _buildHeader(),
                        const SizedBox(height: AppSpacing.xl),
                        _buildOptions(context, state),
                      ],
                    ),
                  ),
                ),
                _buildAction(context, state),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.family_restroom_rounded,
            color: AppColors.primary,
            size: 48,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          'family_group.header_title'.tr(),
          style: AppStyles.displayLarge.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xs),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text(
            'family_group.header_desc'.tr(),
            style: AppStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _buildOptions(BuildContext context, FamilyGroupState state) {
    return Column(
      children: [
        _buildChoiceCard(
          context: context,
          isSelected: state.selectedOption == FamilyGroupOption.create,
          title: 'family_group.create_title'.tr(),
          description: 'family_group.create_desc'.tr(),
          icon: Icons.add_circle_outline,
          color: AppColors.success,
          onTap: () => context
              .read<FamilyGroupCubit>()
              .selectOption(FamilyGroupOption.create),
          child: state.selectedOption == FamilyGroupOption.create
              ? Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.md),
                  child: AppFormField(
                    hintText: 'family_group.group_name_hint'.tr(),
                    onChanged: (val) =>
                        context.read<FamilyGroupCubit>().updateGroupName(val),
                    errorText: state.isSubmitted && state.groupName.isEmpty
                        ? 'family_group.error_empty_name'.tr()
                        : null,
                  ),
                )
              : null,
        ),
        const SizedBox(height: AppSpacing.md),
        _buildChoiceCard(
          context: context,
          isSelected: state.selectedOption == FamilyGroupOption.join,
          title: 'family_group.join_title'.tr(),
          description: 'family_group.join_desc'.tr(),
          icon: Icons.group_add_outlined,
          color: AppColors.primary,
          onTap: () => context
              .read<FamilyGroupCubit>()
              .selectOption(FamilyGroupOption.join),
          child: state.selectedOption == FamilyGroupOption.join
              ? Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.md),
                  child: Column(
                    children: [
                      AppFormField(
                        hintText: 'family_group.invite_code_hint'.tr(),
                        maxLength: 6,
                        textCapitalization: TextCapitalization.characters,
                        textAlign: TextAlign.center,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'[a-zA-Z0-9]')),
                        ],
                        onChanged: (val) => context
                            .read<FamilyGroupCubit>()
                            .updateInviteCode(val),
                        errorText: state.isSubmitted && state.inviteCode.isEmpty
                            ? 'family_group.error_empty_code'.tr()
                            : null,
                      ),
                    ],
                  ),
                )
              : null,
        ),
      ],
    );
  }

  Widget _buildChoiceCard({
    required BuildContext context,
    required bool isSelected,
    required String title,
    required String description,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    Widget? child,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : AppColors.border.withValues(alpha: 0.5),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: color.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: AppStyles.titleMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        description,
                        style: AppStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  const Icon(Icons.check_circle, color: AppColors.success),
              ],
            ),
            if (child != null) child,
          ],
        ),
      ),
    );
  }

  Widget _buildAction(BuildContext context, FamilyGroupState state) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: AppButton.primary(
        title: state.selectedOption == FamilyGroupOption.create
            ? 'family_group.create_button'.tr()
            : 'family_group.join_button'.tr(),
        onPressed: () => context.read<FamilyGroupCubit>().submit(),
        enable: state.pageStatus != PageStatus.Loading,
        icon: state.pageStatus == PageStatus.Loading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : null,
      ),
    );
  }
}
