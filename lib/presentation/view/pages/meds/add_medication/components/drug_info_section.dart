import 'package:easy_localization/easy_localization.dart';
import 'package:family_health/presentation/resources/app_spacing.dart';
import 'package:family_health/presentation/resources/colors.dart';
import 'package:family_health/presentation/resources/styles.dart';
import 'package:family_health/presentation/view/widgets/app_form_field.dart';
import 'package:flutter/material.dart';

/// Section form thông tin thuốc: Tên thuốc + Liều lượng
/// Hiển thị badge ✨ AI khi cần
class DrugInfoSection extends StatelessWidget {
  const DrugInfoSection({
    super.key,
    required this.drugName,
    required this.dosage,
    this.drugNameError,
    this.dosageError,
    required this.onDrugNameChanged,
    required this.onDosageChanged,
    required this.description,
    required this.onDescriptionChanged,
    this.isAiFilled = false,
  });
  final String drugName;
  final String dosage;
  final String? drugNameError;
  final String? dosageError;
  final String description;
  final ValueChanged<String> onDrugNameChanged;
  final ValueChanged<String> onDosageChanged;
  final ValueChanged<String> onDescriptionChanged;
  final bool isAiFilled;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'meds.drug_info_section'.tr(),
              style: AppStyles.titleMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (isAiFilled) _buildAiBadge(),
          ],
        ),
        const SizedBox(height: AppSpacing.md),

        // Card container
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppSpacing.radiusInput),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drug Name field
              Text(
                'meds.drug_name_label'.tr(),
                style: AppStyles.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              _buildInputField(
                value: drugName,
                hintText: 'meds.drug_name_hint'.tr(),
                errorText: drugNameError != null ? drugNameError!.tr() : null,
                onChanged: onDrugNameChanged,
                isAiFilled: isAiFilled,
              ),

              const SizedBox(height: AppSpacing.md),

              // Dosage field
              Text(
                'meds.dosage_label'.tr(),
                style: AppStyles.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              _buildInputField(
                value: dosage,
                hintText: 'meds.dosage_hint'.tr(),
                errorText: dosageError != null ? dosageError!.tr() : null,
                onChanged: onDosageChanged,
                isAiFilled: isAiFilled,
              ),
              const SizedBox(height: AppSpacing.md),
              
              // Description field
              Text(
                'meds.description_label'.tr(),
                style: AppStyles.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              _buildInputField(
                value: description,
                hintText: 'meds.description_hint'.tr(),
                onChanged: onDescriptionChanged,
                isAiFilled: isAiFilled,
                maxLines: 3,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInputField({
    required String value,
    required String hintText,
    String? errorText,
    required ValueChanged<String> onChanged,
    bool isAiFilled = false,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: isAiFilled ? AppColors.aiFilledBackground : AppColors.white,
            borderRadius: BorderRadius.circular(AppSpacing.radiusInput),
            border: errorText != null
                ? Border.all(color: AppColors.error, width: 1)
                : null,
          ),
          child: AppFormField(
            value: value,
            hintText: hintText,
            onChanged: onChanged,
            maxLine: maxLines,
            decoration: InputDecoration(
              fillColor:
                  isAiFilled ? AppColors.aiFilledBackground : AppColors.white,
              suffixIcon: Padding(
                padding: const EdgeInsets.only(right: AppSpacing.md),
                child: Icon(
                  Icons.edit,
                  color: AppColors.primary.withValues(alpha: 0.4),
                  size: 20,
                ),
              ),
            ),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xs),
            child: Text(
              errorText,
              style: AppStyles.labelSmall.copyWith(color: AppColors.error),
            ),
          ),
      ],
    );
  }

  Widget _buildAiBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.aiFilledBackground,
        borderRadius: BorderRadius.circular(AppSpacing.radiusChip),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.auto_awesome, size: 14, color: Color(0xFFA33200)),
          const SizedBox(width: 4),
          Text(
            'meds.ai_filled'.tr(),
            style: AppStyles.labelSmall.copyWith(
              color: const Color(0xFFA33200),
              fontWeight: FontWeight.bold,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
