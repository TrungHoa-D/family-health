import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:family_health/domain/entities/health_profile.dart';
import 'package:family_health/presentation/resources/app_spacing.dart';
import 'package:family_health/presentation/resources/colors.dart';
import 'package:family_health/presentation/resources/styles.dart';
import 'package:family_health/presentation/router/router.dart';
import 'package:family_health/presentation/view/widgets/app_card.dart';
import 'package:family_health/presentation/view/pages/settings/settings_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MedicalRecordsSection extends StatelessWidget {
  const MedicalRecordsSection({super.key, required this.record});
  final HealthProfile record;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.sm,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'settings.medical_records'.tr(),
                style: AppStyles.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  context.router
                      .push(SetupHealthProfileRoute(initialProfile: record))
                      .then((_) {
                    if (context.mounted) {
                      context.read<SettingsCubit>().refreshData();
                    }
                  });
                },
                icon: const Icon(Icons.edit, size: 16),
                label: Text('settings.update_health_profile'.tr()),
                style: TextButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
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
                  value:
                      '${record.bloodType ?? '--'}${record.isRhPositive ? '+' : '-'}',
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _RecordCard(
                  icon: Icons.height,
                  iconColor: AppColors.primary,
                  label: 'settings.height'.tr(),
                  value: record.height,
                  unit: 'cm',
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _RecordCard(
                  icon: Icons.fitness_center,
                  iconColor: AppColors.success,
                  label: 'settings.weight'.tr(),
                  value: record.weight,
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
  const _RecordCard({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    this.unit,
  });
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final String? unit;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.lg,
        horizontal: AppSpacing.sm,
      ),
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
                style:
                    AppStyles.titleLarge.copyWith(fontWeight: FontWeight.w900),
              ),
              if (unit != null)
                Padding(
                  padding: const EdgeInsets.only(left: 2),
                  child: Text(
                    unit!,
                    style: AppStyles.bodySmall
                        .copyWith(color: AppColors.textSecondary),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
