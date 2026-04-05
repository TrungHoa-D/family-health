import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:family_health/presentation/cubit_base/base_cubit_page.dart';
import 'package:family_health/presentation/resources/app_spacing.dart';
import 'package:family_health/presentation/resources/colors.dart';
import 'package:family_health/presentation/resources/styles.dart';
import 'package:family_health/presentation/router/router.dart';
import 'package:family_health/presentation/view/pages/meds/meds_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'components/ai_assistant_card.dart';
import 'components/medication_action_buttons.dart';
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

                // Vùng 4 — AI Assistant Card
                AiAssistantCard(
                  medicationName: med.name,
                  onAskNow: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('meds.ai_coming_soon'.tr()),
                        backgroundColor: AppColors.primary,
                      ),
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.xl),

                // Vùng 3 — Info List
                MedicationInfoList(medication: med),
                const SizedBox(height: AppSpacing.xl),

                // Vùng 5 — Action Buttons
                MedicationActionButtons(
                  onEdit: () {
                    context.router.push(AddMedicationRoute(medication: med.toEntity()));
                  },
                  onCopy: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('meds.copy_coming_soon'.tr()),
                        backgroundColor: AppColors.primary,
                      ),
                    );
                  },
                  onDelete: () => _showDeleteConfirm(context),
                ),
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
      builder: (_) => AlertDialog(
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
            onPressed: () => Navigator.pop(context),
            child: Text(
              'meds.cancel'.tr(),
              style:
                  AppStyles.labelLarge.copyWith(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
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
