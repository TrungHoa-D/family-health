import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:family_health/domain/entities/medication.dart';
import 'package:family_health/domain/entities/patient_schedule.dart';
import 'package:family_health/presentation/cubit_base/base_cubit_page.dart';
import 'package:family_health/presentation/resources/app_spacing.dart';
import 'package:family_health/presentation/resources/colors.dart';
import 'package:family_health/presentation/resources/styles.dart';
import 'package:family_health/presentation/view/widgets/app_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

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

  Future<void> _onScanTap(BuildContext context) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null && context.mounted) {
      context
          .read<AddMedicationCubit>()
          .scanMedicationImage(File(pickedFile.path));
    }
  }

  @override
  Widget builder(BuildContext context) {
    return BlocConsumer<AddMedicationCubit, AddMedicationState>(
      listenWhen: (prev, curr) =>
          prev.isSaved != curr.isSaved ||
          prev.scanError != curr.scanError ||
          prev.saveError != curr.saveError,
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
          return;
        }

        if (state.saveError != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.saveError!),
              backgroundColor: AppColors.error,
            ),
          );
        }

        if (state.scanError != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.scanError!),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        final cubit = context.read<AddMedicationCubit>();

        return Stack(
          children: [
            Scaffold(
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
                  state.isEditing
                      ? 'meds.edit_title'.tr()
                      : 'meds.add_title'.tr(),
                  style: AppStyles.titleLarge
                      .copyWith(color: AppColors.textPrimary),
                ),
                centerTitle: false,
                actions: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md, vertical: 8),
                    child: AppButton.mini(
                      enable: !state.isSaving,
                      title: 'meds.save_button'.tr(),
                      onPressed: () => cubit.save(),
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
                          isScanning: state.isScanning,
                          scannedImage: state.scannedImage,
                          imageUrl: state.imageUrl,
                          onTap: state.isScanning
                              ? null
                              : () => _onScanTap(context),
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

                    // Vùng 3.5 — Category Selection
                    Text(
                      'meds.category_label'.tr(),
                      style: AppStyles.labelLarge.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: () {
                        final defaultCategories = [
                          'HUYẾT ÁP',
                          'TIỂU ĐƯỜNG',
                          'BỔ SUNG',
                          'KHÁC'
                        ];
                        final displayCategories = [...defaultCategories];
                        if (!displayCategories
                            .contains(state.selectedCategory) &&
                            state.selectedCategory.isNotEmpty) {
                          displayCategories.insert(0, state.selectedCategory);
                        }

                        return displayCategories.map((cat) {
                          final isSelected = state.selectedCategory == cat;
                          return ChoiceChip(
                            label: Text(cat),
                            selected: isSelected,
                            onSelected: (_) => cubit.selectCategory(cat),
                            selectedColor: AppColors.primary,
                            backgroundColor: Colors.grey[200],
                            labelStyle: AppStyles.labelLarge.copyWith(
                              color: isSelected ? Colors.white : Colors.black87,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(AppSpacing.radiusButton),
                              side: BorderSide.none,
                            ),
                            showCheckmark: false,
                          );
                        }).toList();
                      }(),
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
            ),
            // Loading overlay khi đang lưu
            if (state.isSaving)
              Container(
                color: Colors.black26,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        );
      },
    );
  }
}
