import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:family_health/di/di.dart';
import 'package:family_health/presentation/cubit_base/base_cubit_page.dart';
import 'package:family_health/presentation/resources/app_spacing.dart';
import 'package:family_health/presentation/resources/colors.dart';
import 'package:family_health/presentation/resources/styles.dart';
import 'package:family_health/presentation/router/router.dart';
import 'package:family_health/presentation/view/pages/meds/meds_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'ai_chat_cubit.dart';
import 'components/animated_ai_fab.dart';
import 'components/ai_chat_bottom_sheet.dart';
import 'components/medication_hero_section.dart';
import 'components/medication_info_list.dart';
import 'medication_detail_cubit.dart';

@RoutePage()
class MedicationDetailPage
    extends BaseCubitPage<MedicationDetailCubit, MedicationDetailState> {
  const MedicationDetailPage({
    super.key,
    required this.medication,
  });
  final MedicationModel medication;

  @override
  void onInitState(BuildContext context) {
    super.onInitState(context);
    context.read<MedicationDetailCubit>().loadMedication(medication);
  }

  @override
  Widget builder(BuildContext context) {
    return BlocBuilder<MedicationDetailCubit, MedicationDetailState>(
      builder: (context, state) {
        final med = state.medication;
        if (med == null) {
          return const SizedBox.shrink();
        }

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
              'meds.detail_page_title'.tr(),
              style:
                  AppStyles.titleLarge.copyWith(color: AppColors.textPrimary),
            ),
            centerTitle: true,
            actions: [
              IconButton(
                icon: const Icon(Icons.edit, color: AppColors.primary),
                onPressed: () {
                  context.router
                      .push(AddMedicationRoute(medication: med.toEntity()))
                      .then((_) {
                    if (context.mounted) {
                      context.router.maybePop();
                    }
                  });
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: AppColors.error),
                onPressed: () => _showDeleteConfirm(context),
              ),
            ],
          ),
          floatingActionButton: AnimatedAiFab(
            medicationName: med.name,
            onTap: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => BlocProvider(
                  create: (context) => getIt<AIChatCubit>(),
                  child: AiChatBottomSheet(medicationName: med.name),
                ),
              );
            },
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
            ),
            child: Column(
              children: [
                const SizedBox(height: AppSpacing.lg),

                // Vùng 2 — Hero Section
                MedicationHeroSection(medication: med),
                const SizedBox(height: AppSpacing.xl),

                // Vùng 3 — Info List
                MedicationInfoList(medication: med),
                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDeleteConfirm(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        ),
        title: Text(
          'meds.delete_confirm_title'.tr(),
          style: AppStyles.titleMedium,
        ),
        content: Text(
          'meds.delete_confirm_desc'.tr(),
          style: AppStyles.bodyMedium.copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(
              'meds.cancel'.tr(),
              style:
                  AppStyles.labelLarge.copyWith(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<MedicationDetailCubit>().deleteMedication();
              context.router.maybePop();
            },
            child: Text(
              'meds.action_delete'.tr(),
              style: AppStyles.labelLarge.copyWith(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
