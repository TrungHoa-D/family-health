import 'package:easy_localization/easy_localization.dart';
import 'package:family_health/presentation/resources/app_spacing.dart';
import 'package:family_health/presentation/resources/colors.dart';
import 'package:family_health/presentation/resources/styles.dart';
import 'package:family_health/presentation/view/pages/settings/settings_state.dart';
import 'package:family_health/presentation/view/widgets/app_card.dart';
import 'package:flutter/material.dart';

class MedicalRecordsSection extends StatelessWidget {
  final MedicalRecord record;

  const MedicalRecordsSection({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          child: Text(
            'settings.medical_records'.tr(),
            style: AppStyles.labelSmall.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Row(
            children: [
              Expanded(
                child: _RecordCard(
                  icon: Icons.bloodtype,
                  iconColor: AppColors.error,
                  label: 'settings.blood_type'.tr(),
                  value: record.bloodType,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _RecordCard(
                  icon: Icons.height,
                  iconColor: AppColors.primary,
                  label: 'settings.height'.tr(),
                  value: record.heightCm.toString(),
                  unit: 'cm',
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _RecordCard(
                  icon: Icons.fitness_center,
                  iconColor: AppColors.success,
                  label: 'settings.weight'.tr(),
                  value: record.weightKg.toString(),
                  unit: 'kg',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RecordCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String? unit;

  const _RecordCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg, horizontal: AppSpacing.sm),
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(height: 8),
          Text(
            label.toUpperCase(),
            style: AppStyles.labelSmall.copyWith(
              color: AppColors.textSecondary,
              fontSize: 9,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: AppStyles.titleLarge.copyWith(fontWeight: FontWeight.w900),
              ),
              if (unit != null)
                Padding(
                  padding: const EdgeInsets.only(left: 2),
                  child: Text(
                    unit!,
                    style: AppStyles.bodySmall.copyWith(color: AppColors.textSecondary),
                  ),
                ),
            ],
          )
        ],
      ),
    );
  }
}
