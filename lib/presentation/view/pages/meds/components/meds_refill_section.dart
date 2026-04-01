import 'package:easy_localization/easy_localization.dart';
import 'package:family_health/presentation/resources/app_spacing.dart';
import 'package:family_health/presentation/resources/colors.dart';
import 'package:family_health/presentation/resources/styles.dart';
import 'package:family_health/presentation/view/widgets/app_button.dart';
import 'package:family_health/presentation/view/widgets/app_card.dart';
import 'package:flutter/material.dart';
import '../meds_cubit.dart';

class MedsRefillSection extends StatelessWidget {
  final List<MedicationRefillModel> refills;

  const MedsRefillSection({super.key, required this.refills});

  @override
  Widget build(BuildContext context) {
    if (refills.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
          child: Text(
            'meds.refill_label'.tr(),
            style: AppStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        ...refills.map((refill) => _RefillCard(refill: refill)),
      ],
    );
  }
}

class _RefillCard extends StatelessWidget {
  final MedicationRefillModel refill;

  const _RefillCard({required this.refill});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      backgroundColor: AppColors.surface,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha:0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 24),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  refill.name,
                  style: AppStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  'meds.remaining_pills'.tr(args: [refill.remainingPills.toString()]),
                  style: AppStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                ),
              ],
            ),
          ),
          AppButton(
            height: 36,
            minWidth: 100,
            onPressed: () {},
            child: Text(
              'meds.order_now'.tr(),
              style: AppStyles.labelSmall.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
