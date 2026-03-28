import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:family_health/presentation/cubit_base/base_cubit_page.dart';
import 'package:family_health/presentation/resources/app_spacing.dart';
import 'package:family_health/presentation/resources/colors.dart';
import 'package:family_health/presentation/resources/styles.dart';
import 'package:family_health/presentation/router/router.dart';
import 'package:family_health/presentation/view/widgets/app_card.dart';
import 'package:family_health/presentation/view/widgets/app_form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'setup_health_profile_cubit.dart';

@RoutePage()
class SetupHealthProfilePage
    extends BaseCubitPage<SetupHealthProfileCubit, SetupHealthProfileState> {
  const SetupHealthProfilePage({super.key});

  @override
  void onInitState(BuildContext context) {
    super.onInitState(context);
    context.read<SetupHealthProfileCubit>().init();
  }

  @override
  Widget builder(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: AppSpacing.xxl),
                _buildHeader(),
                const SizedBox(height: AppSpacing.xl),
                _buildFormSections(),
                const SizedBox(height: AppSpacing.xxl),
                _buildFooter(context),
              ],
            ),
          ),
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
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.medical_information_outlined,
            color: AppColors.white,
            size: 32,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          'setup_health_profile.title'.tr(),
          style: AppStyles.displayLarge.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'setup_health_profile.subtitle'.tr(),
          style: AppStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: AppSpacing.md),
        // Stepper Indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
                width: 24,
                height: 6,
                decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(100))),
            const SizedBox(width: AppSpacing.xs),
            Container(
                width: 24,
                height: 6,
                decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(100))),
            const SizedBox(width: AppSpacing.xs),
            Container(
                width: 48,
                height: 6,
                decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(100),
                    boxShadow: [
                      BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.2),
                          blurRadius: 4)
                    ])),
          ],
        ),
      ],
    );
  }

  Widget _buildFormSections() {
    return BlocBuilder<SetupHealthProfileCubit, SetupHealthProfileState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Biometric Data Grid
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: _buildInputSection(
                    context: context,
                    title: 'setup_health_profile.height'.tr(),
                    hint: '170',
                    suffixText: 'cm',
                    value: state.height,
                    errorText: state.heightError,
                    onChanged: (val) => context
                        .read<SetupHealthProfileCubit>()
                        .updateHeight(val),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: _buildInputSection(
                    context: context,
                    title: 'setup_health_profile.weight'.tr(),
                    hint: '65',
                    suffixText: 'kg',
                    value: state.weight,
                    errorText: state.weightError,
                    onChanged: (val) => context
                        .read<SetupHealthProfileCubit>()
                        .updateWeight(val),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.xl),

            // Blood Type Selection
            _buildBloodTypeSelection(context, state),

            const SizedBox(height: AppSpacing.xl),

            // Medical History Multi-select Chips
            _buildMedicalHistory(context, state),

            const SizedBox(height: AppSpacing.xl),

            // Health Information Visualization Card
            _buildRiskLevelCard(),
          ],
        );
      },
    );
  }

  Widget _buildInputSection({
    required BuildContext context,
    required String title,
    required String hint,
    required String suffixText,
    required String value,
    String? errorText,
    required Function(String) onChanged,
  }) {
    // Generate localized error message
    String? localizedError;
    if (errorText == 'required') {
      localizedError = 'error.field_is_required'.tr();
    } else if (errorText == 'invalid') {
      localizedError = 'Dữ liệu không hợp lệ';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0),
          child: Text(
            title.toUpperCase(),
            style: AppStyles.labelSmall.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        AppFormField(
          hintText: hint,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
          ],
          onChanged: onChanged,
          errorText: localizedError,
          decoration: InputDecoration(
            suffixIcon: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    suffixText,
                    style: AppStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBloodTypeSelection(
      BuildContext context, SetupHealthProfileState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0),
          child: Row(
            children: [
              Text(
                'setup_health_profile.blood_type'.tr().toUpperCase(),
                style: AppStyles.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
              if (state.bloodTypeError != null)
                Padding(
                  padding: const EdgeInsets.only(left: AppSpacing.sm),
                  child: Text(
                    '* ${'error.field_is_required'.tr()}',
                    style:
                        AppStyles.labelSmall.copyWith(color: AppColors.error),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Row(
          children: [
            _buildBloodTypeButton(context, 'A', state.selectedBloodType == 'A'),
            const SizedBox(width: AppSpacing.sm),
            _buildBloodTypeButton(context, 'B', state.selectedBloodType == 'B'),
            const SizedBox(width: AppSpacing.sm),
            _buildBloodTypeButton(context, 'O', state.selectedBloodType == 'O'),
            const SizedBox(width: AppSpacing.sm),
            _buildBloodTypeButton(
                context, 'AB', state.selectedBloodType == 'AB'),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(100),
          ),
          child: Row(
            children: [
              Expanded(
                  child: _buildRhToggleButton(
                      context, 'Rh+', true, state.isRhPositive)),
              Expanded(
                  child: _buildRhToggleButton(
                      context, 'Rh-', false, !state.isRhPositive)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBloodTypeButton(
      BuildContext context, String type, bool isSelected) {
    return Expanded(
      child: GestureDetector(
        onTap: () =>
            context.read<SetupHealthProfileCubit>().selectBloodType(type),
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primary.withValues(alpha: 0.1)
                : AppColors.surface,
            border: Border.all(
              color: isSelected ? AppColors.primary : Colors.transparent,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Text(
            type,
            style: AppStyles.titleMedium.copyWith(
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRhToggleButton(
      BuildContext context, String label, bool value, bool isSelected) {
    return GestureDetector(
      onTap: () =>
          context.read<SetupHealthProfileCubit>().toggleRhFactor(value),
      child: Container(
        height: 36,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(100),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2))
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: AppStyles.labelMedium.copyWith(
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget _buildMedicalHistory(
      BuildContext context, SetupHealthProfileState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                'setup_health_profile.medical_history'.tr().toUpperCase(),
                style: AppStyles.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.5,
                ),
              ),
              Text(
                'setup_health_profile.select_all_applicable'.tr(),
                style: AppStyles.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.sm,
          children: [
            _buildDiseaseChip(context, state,
                'setup_health_profile.diabetes'.tr(), 'diabetes'),
            _buildDiseaseChip(context, state,
                'setup_health_profile.blood_pressure'.tr(), 'blood_pressure'),
            _buildDiseaseChip(context, state,
                'setup_health_profile.cardiovascular'.tr(), 'cardiovascular'),
            _buildDiseaseChip(context, state,
                'setup_health_profile.allergies'.tr(), 'allergies'),
            _buildDiseaseChip(
                context, state, 'setup_health_profile.asthma'.tr(), 'asthma'),
            _buildDiseaseChip(
                context, state, 'setup_health_profile.stomach'.tr(), 'stomach'),
            _buildAddOtherChip(context, state),
          ],
        ),
        if (state.isShowingOtherDiseaseInput) ...[
          const SizedBox(height: AppSpacing.md),
          AppFormField(
            hintText: 'setup_health_profile.enter_other_disease'.tr(),
            onChanged: (val) =>
                context.read<SetupHealthProfileCubit>().updateOtherDisease(val),
          ),
        ]
      ],
    );
  }

  Widget _buildDiseaseChip(BuildContext context, SetupHealthProfileState state,
      String label, String key) {
    final isSelected = state.selectedDiseases.contains(key);
    return GestureDetector(
      onTap: () => context.read<SetupHealthProfileCubit>().toggleDisease(key),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryLight : AppColors.surface,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: AppStyles.bodySmall.copyWith(
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: AppSpacing.xs),
              const Icon(Icons.check_circle,
                  size: 16, color: AppColors.primary),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAddOtherChip(
      BuildContext context, SetupHealthProfileState state) {
    final isSelected = state.isShowingOtherDiseaseInput;
    return GestureDetector(
      onTap: () =>
          context.read<SetupHealthProfileCubit>().toggleOtherDiseaseInput(),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryLight : AppColors.surface,
          borderRadius: BorderRadius.circular(100),
          border: Border.all(
              color: isSelected
                  ? AppColors.primary
                  : AppColors.border.withValues(alpha: 0.5),
              style: BorderStyle.solid),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add,
                size: 16,
                color:
                    isSelected ? AppColors.primary : AppColors.textSecondary),
            const SizedBox(width: AppSpacing.xs),
            Text(
              'setup_health_profile.add_other_disease'.tr(),
              style: AppStyles.bodySmall.copyWith(
                color: isSelected ? AppColors.primary : AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRiskLevelCard() {
    return AppCard(
      enableShadow: true,
      hasBorder: true,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'setup_health_profile.current_risk_level'.tr(),
                        style: AppStyles.titleMedium.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'setup_health_profile.based_on_provided_info'.tr(),
                        style: AppStyles.bodySmall.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Text(
                          'setup_health_profile.normal'.tr().toUpperCase(),
                          style: AppStyles.labelSmall.copyWith(
                            color: AppColors.success,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Custom Health Progress Ring
                SizedBox(
                  width: 80,
                  height: 80,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 80,
                        height: 80,
                        child: CircularProgressIndicator(
                          value: 0.75,
                          strokeWidth: 8,
                          backgroundColor:
                              AppColors.success.withValues(alpha: 0.3),
                          color: AppColors.success,
                        ),
                      ),
                      Text(
                        '75%',
                        style: AppStyles.titleLarge.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Abstract visual element blur (simulated)
          Positioned(
            bottom: -24,
            right: -24,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.05),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            height: 56, // Large button
            child: ElevatedButton(
              onPressed: () {
                final cubit = context.read<SetupHealthProfileCubit>();
                if (cubit.submitForm()) {
                  context.router.push(const FamilySetupRoute());
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100),
                ),
                elevation: 4,
                shadowColor: AppColors.primary.withValues(alpha: 0.5),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'setup_health_profile.complete'.tr(),
                    style: AppStyles.titleMedium.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  const Icon(Icons.arrow_forward, color: AppColors.white),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          GestureDetector(
            onTap: () {
              context.router.replaceAll([const HomeRoute()]);
            },
            child: Text(
              'setup_health_profile.update_later'.tr(),
              style: AppStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
