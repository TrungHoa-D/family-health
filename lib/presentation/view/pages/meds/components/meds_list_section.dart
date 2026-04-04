import 'package:easy_localization/easy_localization.dart';
import 'package:family_health/presentation/resources/app_spacing.dart';
import 'package:family_health/presentation/resources/colors.dart';
import 'package:family_health/presentation/resources/styles.dart';
import 'package:flutter/material.dart';
import '../meds_cubit.dart';
import 'meds_card.dart';

class MedsListSection extends StatelessWidget {
  const MedsListSection({
    super.key,
    required this.medications,
    this.onMedicationTap,
  });
  final List<MedicationModel> medications;
  final ValueChanged<MedicationModel>? onMedicationTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'meds.current_list_label'.tr(),
                  style: AppStyles.labelLarge.copyWith(
                    color: AppColors.textSecondary,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'meds.meds_count'.tr(args: [medications.length.toString()]),
                style: AppStyles.labelMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: medications.length,
          itemBuilder: (context, index) {
            return MedsCard(
              medication: medications[index],
              onTap: onMedicationTap != null
                  ? () => onMedicationTap!(medications[index])
                  : null,
            );
          },
        ),
      ],
    );
  }
}
