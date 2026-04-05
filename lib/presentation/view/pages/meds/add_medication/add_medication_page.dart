import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:family_health/presentation/cubit_base/base_cubit_page.dart';
import 'package:family_health/presentation/resources/app_spacing.dart';
import 'package:family_health/presentation/resources/colors.dart';
import 'package:family_health/presentation/resources/styles.dart';
import 'package:family_health/domain/entities/medication.dart';
import 'package:family_health/domain/entities/patient_schedule.dart';
import 'package:family_health/presentation/view/widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'add_medication_cubit.dart';
import 'components/ai_scanner_card.dart';
import 'components/drug_info_section.dart';
import 'components/schedule_section.dart';

@RoutePage()
class AddMedicationPage
    extends BaseCubitPage<AddMedicationCubit, AddMedicationState> {
  const AddMedicationPage({
    super.key,
    this.medication,
    this.schedule,
  });
  final Medication? medication;
  final PatientSchedule? schedule;

  @override
  void onInitState(BuildContext context) {
    super.onInitState(context);
    context.read<AddMedicationCubit>().init(
          medication: medication,
          schedule: schedule,
        );
  }

  @override
  Widget builder(BuildContext context) {
    return BlocConsumer<AddMedicationCubit, AddMedicationState>(
      listenWhen: (prev, curr) => prev.isSaved != curr.isSaved,
      listener: (context, state) {
        if (state.isSaved) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.isEditing
                    ? 'meds.save_success_edit'.tr()
                    : 'meds.save_success'.tr(),
              ),
              backgroundColor: AppColors.success,
            ),
          );
          context.router.maybePop();
        }
      },
      builder: (context, state) {
        final cubit = context.read<AddMedicationCubit>();

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
              state.isEditing ? 'meds.edit_title'.tr() : 'meds.add_title'.tr(),
              style:
                  AppStyles.titleLarge.copyWith(color: AppColors.textPrimary),
            ),
            centerTitle: false,
            actions: [
              if (!state.isEditing)
                Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.md),
                  child: Text(
                    'AI HEALTH',
                    style: AppStyles.titleSmall.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.lg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Vùng 2 — AI Scanner
                if (!state.isEditing)
                  Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.xl),
                    child: AiScannerCard(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('meds.ai_coming_soon'.tr()),
                            backgroundColor: AppColors.primary,
                          ),
                        );
                      },
                    ),
                  ),

                // Vùng 3 — Drug Info Section
                DrugInfoSection(
                  drugName: state.drugName,
                  dosage: state.dosage,
                  drugNameError: state.drugNameError,
                  dosageError: state.dosageError,
                  onDrugNameChanged: cubit.updateDrugName,
                  onDosageChanged: cubit.updateDosage,
                ),

                const SizedBox(height: AppSpacing.xl),

                // Vùng 4 — Schedule Section
                ScheduleSection(
                  selectedUser: state.selectedUser,
                  anchorTime: state.anchorTime,
                  offset: state.offset,
                  supervisor: state.supervisor,
                  onUserChanged: cubit.selectUser,
                  onAnchorTimeChanged: cubit.selectAnchorTime,
                  onOffsetChanged: cubit.selectOffset,
                  onSupervisorChanged: cubit.selectSupervisor,
                ),

                const SizedBox(height: AppSpacing.xl),

                // Vùng 5 — Save Button
                AppButton.primary(
                  title: 'meds.save_button'.tr(),
                  icon:
                      const Icon(Icons.save, color: AppColors.white, size: 20),
                  onPressed: cubit.save,
                ),

                const SizedBox(height: AppSpacing.md),

                // Footer
                Center(
                  child: Text(
                    'meds.ai_support_footer'.tr(),
                    style: AppStyles.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),

                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          ),
        );
      },
    );
  }
}
