import 'package:easy_localization/easy_localization.dart';
import 'package:family_health/presentation/resources/app_spacing.dart';
import 'package:family_health/presentation/resources/colors.dart';
import 'package:family_health/presentation/resources/styles.dart';
import 'package:family_health/presentation/view/widgets/app_card.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DashboardScheduleSection extends StatelessWidget {
  const DashboardScheduleSection({
    super.key,
    required this.schedules,
  });
  final List<DashboardScheduleModel> schedules;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Row(
            children: [
              const Text('📅', style: TextStyle(fontSize: 20)),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'home.next_schedule'.tr(),
                style:
                    AppStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        ...schedules.map((schedule) => _ScheduleCard(schedule: schedule)),
      ],
    );
  }
}

class DashboardScheduleModel {
  DashboardScheduleModel({
    required this.title,
    required this.dateTime,
    required this.location,
    this.onTap,
  });
  final String title;
  final DateTime dateTime;
  final String location;
  final VoidCallback? onTap;
}

class _ScheduleCard extends StatelessWidget {
  const _ScheduleCard({required this.schedule});
  final DashboardScheduleModel schedule;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      backgroundColor: AppColors.primary.withValues(alpha: 0.05),
      hasBorder: true,
      borderColor: AppColors.primary.withValues(alpha: 0.1),
      onPressed: schedule.onTap,
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(AppSpacing.radiusInput),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  DateFormat('MMM', 'vi').format(schedule.dateTime).toUpperCase(),
                  style: AppStyles.labelSmall.copyWith(
                    color: AppColors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  schedule.dateTime.day.toString(),
                  style: AppStyles.titleLarge.copyWith(
                    color: AppColors.white,
                    fontWeight: FontWeight.w900,
                    height: 1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  schedule.title,
                  style: AppStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '${DateFormat('HH:mm').format(schedule.dateTime)} • ${schedule.location}',
                  style: AppStyles.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios,
            color: AppColors.primary,
            size: 16,
          ),
        ],
      ),
    );
  }
}
