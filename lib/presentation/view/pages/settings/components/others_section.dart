import 'package:easy_localization/easy_localization.dart';
import 'package:family_health/presentation/resources/app_spacing.dart';
import 'package:family_health/presentation/resources/colors.dart';
import 'package:family_health/presentation/resources/styles.dart';
import 'package:family_health/presentation/view/widgets/app_card.dart';
import 'package:flutter/material.dart';

class OthersSection extends StatelessWidget {
  const OthersSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          child: Text(
            'settings.others'.tr(),
            style: AppStyles.labelSmall.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
        ),
        AppCard(
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.help, color: AppColors.textSecondary),
                title: Text('settings.help_center'.tr(), style: AppStyles.titleMedium),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.textSecondary),
                onTap: () {},
              ),
              const Divider(height: 1, color: AppColors.border),
              ListTile(
                leading: const Icon(Icons.logout, color: AppColors.error),
                title: Text(
                  'settings.logout'.tr(),
                  style: AppStyles.titleMedium.copyWith(color: AppColors.error, fontWeight: FontWeight.bold),
                ),
                onTap: () {},
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Center(
          child: Text(
            'settings.version'.tr(args: ['2.4.0']),
            style: AppStyles.labelSmall.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
        ),
        const SizedBox(height: 120), // Bottom padding for navigation bar
      ],
    );
  }
}
