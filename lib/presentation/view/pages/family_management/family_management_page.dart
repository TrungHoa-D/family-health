import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:family_health/presentation/cubit_base/base_cubit_page.dart';
import 'package:family_health/presentation/resources/app_spacing.dart';
import 'package:family_health/presentation/resources/colors.dart';
import 'package:family_health/presentation/resources/styles.dart';
import 'package:family_health/presentation/router/router.dart';
import 'package:family_health/presentation/view/widgets/app_avatar.dart';
import 'package:family_health/presentation/view/widgets/app_button.dart';
import 'package:family_health/presentation/base/page_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'family_management_cubit.dart';

@RoutePage()
class FamilyManagementPage
    extends BaseCubitPage<FamilyManagementCubit, FamilyManagementState> {
  const FamilyManagementPage({super.key});

  @override
  void onInitState(BuildContext context) {
    super.onInitState(context);
    context.read<FamilyManagementCubit>().loadData();
  }

  @override
  Widget builder(BuildContext context) {
    return BlocConsumer<FamilyManagementCubit, FamilyManagementState>(
      listenWhen: (prev, curr) => prev.isLeaved != curr.isLeaved,
      listener: (context, state) {
        if (state.isLeaved) {
          context.router.replaceAll([const FamilySetupRoute()]);
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.white,
            elevation: 0,
            surfaceTintColor: Colors.transparent,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.primary),
              onPressed: () => context.router.maybePop(),
            ),
            title: Text(
              'family.management_title'.tr(),
              style:
                  AppStyles.titleLarge.copyWith(color: AppColors.textPrimary),
            ),
          ),
          body: state.pageStatus == PageStatus.Loading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.lg,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(state),
                      const SizedBox(height: AppSpacing.xl),
                      _buildMembersList(state),
                      const SizedBox(height: AppSpacing.xl),
                      if (state.isAdmin) _buildInviteSection(context, state),
                      const SizedBox(height: AppSpacing.xxl),
                      _buildActionButtons(context, state),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _buildHeader(FamilyManagementState state) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
      ),
      child: Row(
        children: [
          const Icon(Icons.groups, color: AppColors.primary, size: 40),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state.family?.familyName ?? '',
                  style: AppStyles.headlineMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  'family.member_count'
                      .tr(args: [state.members.length.toString()]),
                  style: AppStyles.bodySmall
                      .copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMembersList(FamilyManagementState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'family.members_label'.tr(),
          style: AppStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppSpacing.md),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: state.members.length,
          separatorBuilder: (_, __) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final member = state.members[index];
            final isAdmin = member.uid == state.family?.adminId;

            return ListTile(
              contentPadding: EdgeInsets.zero,
              leading: AppAvatar(
                imageUrl: member.avatarUrl ?? '',
                size: 40,
              ),
              title: Text(
                member.displayName ?? '',
                style:
                    AppStyles.titleSmall.copyWith(fontWeight: FontWeight.w600),
              ),
              subtitle: Text(
                member.email ?? '',
                style: AppStyles.labelSmall
                    .copyWith(color: AppColors.textSecondary),
              ),
              trailing: isAdmin
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'family.role_admin'.tr(),
                        style: AppStyles.labelSmall.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : null,
            );
          },
        ),
      ],
    );
  }

  Widget _buildInviteSection(
      BuildContext context, FamilyManagementState state) {
    final inviteCode = state.family?.invitationCode ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'family.invite_code_label'.tr(),
          style: AppStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              Text(
                inviteCode,
                style: AppStyles.headlineMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 4.0,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              AppButton.primary(
                title: 'family.copy_code'.tr(),
                icon: const Icon(Icons.copy, color: AppColors.white, size: 18),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: inviteCode));
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('family.code_copied'.tr())),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(
      BuildContext context, FamilyManagementState state) {
    if (state.isAdmin) {
      return Padding(
        padding: const EdgeInsets.only(top: AppSpacing.md, bottom: AppSpacing.xxl),
        child: SizedBox(
          width: double.infinity,
          child: AppButton.primary(
            title: 'family.disband_group'.tr(),
            onPressed: () => _showConfirmDialog(
              context,
              title: 'family.disband_confirm_title'.tr(),
              content: 'family.disband_confirm_desc'.tr(),
              onConfirm: () => context.read<FamilyManagementCubit>().disbandGroup(),
              isDanger: true,
            ),
            backgroundColor: AppColors.error,
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.md, bottom: AppSpacing.xxl),
      child: SizedBox(
        width: double.infinity,
        child: AppButton.primary(
          title: 'family.leave_group'.tr(),
          onPressed: () => _showConfirmDialog(
            context,
            title: 'family.leave_confirm_title'.tr(),
            content: 'family.leave_confirm_desc'.tr(),
            onConfirm: () => context.read<FamilyManagementCubit>().leaveFamily(),
            isDanger: true,
          ),
          backgroundColor: AppColors.error,
        ),
      ),
    );
  }

  void _showConfirmDialog(
    BuildContext context, {
    required String title,
    required String content,
    required VoidCallback onConfirm,
    bool isDanger = false,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('common.cancel'.tr()),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onConfirm();
            },
            child: Text(
              'common.confirm'.tr(),
              style: TextStyle(
                  color: isDanger ? AppColors.error : AppColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}
