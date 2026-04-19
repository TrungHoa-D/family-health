import 'package:easy_localization/easy_localization.dart';
import 'package:family_health/presentation/resources/app_spacing.dart';
import 'package:family_health/presentation/resources/colors.dart';
import 'package:family_health/presentation/resources/styles.dart';
import 'package:family_health/presentation/view/widgets/app_card.dart';
import 'package:flutter/material.dart';

class DashboardOverviewCard extends StatelessWidget {
  const DashboardOverviewCard({
    super.key,
    required this.progress,
    required this.takenCount,
    required this.totalCount,
    required this.waitingCount,
    required this.missedCount,
  });
  final double progress; // 0.0 to 1.0 (e.g. 0.67)
  final int takenCount;
  final int totalCount;
  final int waitingCount;
  final int missedCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppCard(
          margin: const EdgeInsets.all(AppSpacing.md),
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${(progress * 100).toInt()}%',
                          style: AppStyles.displayLarge.copyWith(
                            color: AppColors.primary,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          'home.total_progress'.tr(),
                          style: AppStyles.labelSmall.copyWith(
                            color: AppColors.textSecondary,
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppSpacing.sm),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 10,
                  backgroundColor: AppColors.surface,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(AppColors.secondary),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      '$takenCount/$totalCount',
                      'home.taken'.tr(),
                      AppColors.secondary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _buildStatItem(
                      waitingCount.toString(),
                      'home.waiting'.tr(),
                      AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: _buildStatItem(
                      missedCount.toString(),
                      'home.missed'.tr(),
                      AppColors.error,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.md,
      ),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: AppStyles.titleLarge.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: AppStyles.labelSmall.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.bold,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}
