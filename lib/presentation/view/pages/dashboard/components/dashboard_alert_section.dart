import 'package:easy_localization/easy_localization.dart';
import 'package:family_health/presentation/resources/app_spacing.dart';
import 'package:family_health/presentation/resources/colors.dart';
import 'package:family_health/presentation/resources/styles.dart';
import 'package:family_health/presentation/view/widgets/app_button.dart';
import 'package:flutter/material.dart';

class DashboardAlertSection extends StatelessWidget {
  const DashboardAlertSection({
    super.key,
    required this.alerts,
  });
  final List<DashboardAlertItem> alerts;

  @override
  Widget build(BuildContext context) {
    if (alerts.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Row(
            children: [
              const Text('⚠️', style: TextStyle(fontSize: 20)),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'home.alerts'.tr(),
                style:
                    AppStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        ...alerts.map((alert) => _AlertCard(alert: alert)),
      ],
    );
  }
}

class DashboardAlertItem {
  DashboardAlertItem({
    required this.personName,
    required this.actionName,
    required this.minutesLate,
    this.onRemind,
    this.onView,
  });
  final String personName;
  final String actionName;
  final int minutesLate;
  final VoidCallback? onRemind;
  final VoidCallback? onView;
}

class _AlertCard extends StatelessWidget {
  const _AlertCard({required this.alert});
  final DashboardAlertItem alert;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.alertBackground,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        border: const Border(
          left: BorderSide(color: AppColors.error, width: 4),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.error, color: AppColors.error, size: 24),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    style: AppStyles.bodyMedium.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                    children: [
                      const TextSpan(
                        text: '🔴 ',
                        style: TextStyle(color: AppColors.error),
                      ),
                      TextSpan(
                        text: 'home.alert_msg'.tr(
                          args: [
                            alert.personName,
                            alert.actionName,
                            alert.minutesLate.toString(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        height: 36,
                        backgroundColor: AppColors.white,
                        borderColor: AppColors.border.withValues(alpha: 0.5),
                        borderRadius: AppSpacing.radiusButton,
                        onPressed: alert.onRemind ?? () {},
                        child: Text(
                          'home.remind'.tr(),
                          style: AppStyles.labelMedium
                              .copyWith(color: AppColors.textPrimary),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: AppButton(
                        height: 36,
                        backgroundColor: AppColors.error,
                        borderRadius: AppSpacing.radiusButton,
                        onPressed: alert.onView ?? () {},
                        child: Text(
                          'home.view'.tr(),
                          style: AppStyles.labelMedium
                              .copyWith(color: AppColors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
