import 'package:easy_localization/easy_localization.dart';
import 'package:family_health/presentation/resources/app_spacing.dart';
import 'package:family_health/presentation/resources/colors.dart';
import 'package:family_health/presentation/resources/styles.dart';
import 'package:family_health/presentation/view/widgets/app_card.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum DashboardScheduleMode { ongoing, upcoming }

class DashboardScheduleSection extends StatelessWidget {
  const DashboardScheduleSection({
    super.key,
    required this.schedules,
    this.mode = DashboardScheduleMode.upcoming,
  });
  final List<DashboardScheduleModel> schedules;
  final DashboardScheduleMode mode;

  @override
  Widget build(BuildContext context) {
    final isOngoing = mode == DashboardScheduleMode.ongoing;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text(
            isOngoing
                ? 'home.ongoing_events'.tr()
                : 'home.next_schedule'.tr(),
            style: AppStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        ...schedules.map((schedule) =>
            _ScheduleCard(schedule: schedule, mode: mode)),
      ],
    );
  }
}

class DashboardScheduleModel {
  DashboardScheduleModel({
    required this.title,
    required this.dateTime,
    required this.location,
    this.isAllDay = false,
    this.imageUrl,
    this.eventType = 'OTHER',
    this.onTap,
  });
  final String title;
  final DateTime dateTime;
  final String location;
  final bool isAllDay;
  final String? imageUrl;
  final String eventType;
  final VoidCallback? onTap;

  /// Trả về đường dẫn asset ảnh mặc định theo loại sự kiện
  String get fallbackAsset {
    switch (eventType.toUpperCase()) {
      case 'VACCINE':
        return 'assets/images/event_vaccine.png';
      case 'CHECKUP':
        return 'assets/images/event_checkup.png';
      case 'DENTAL':
        return 'assets/images/event_dental.png';
      case 'MEDICATION':
        return 'assets/images/event_medication.png';
      default:
        return 'assets/images/event_other.png';
    }
  }
}

class _ScheduleCard extends StatelessWidget {
  const _ScheduleCard({required this.schedule, required this.mode});
  final DashboardScheduleModel schedule;
  final DashboardScheduleMode mode;

  @override
  Widget build(BuildContext context) {
    final isOngoing = mode == DashboardScheduleMode.ongoing;
    final accentColor = isOngoing ? AppColors.success : AppColors.primary;

    return AppCard(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      backgroundColor: accentColor.withValues(alpha: 0.05),
      hasBorder: true,
      borderColor: accentColor.withValues(alpha: 0.15),
      onPressed: schedule.onTap,
      child: Row(
        children: [
          // Thumbnail: hiển thị ảnh event nếu có, nếu không thì fallback icon ngày
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.radiusInput),
            child: SizedBox(
              width: 50,
              height: 50,
              child: schedule.imageUrl != null && schedule.imageUrl!.isNotEmpty
                  ? Image.network(
                      schedule.imageUrl!,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          _buildFallbackThumbnail(accentColor, isOngoing),
                    )
                  : _buildFallbackThumbnail(accentColor, isOngoing),
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  schedule.isAllDay
                      ? 'home.all_day'.tr()
                      : '${DateFormat('HH:mm').format(schedule.dateTime)} • ${schedule.location}',
                  style: AppStyles.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            color: accentColor,
            size: 16,
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackThumbnail(Color accentColor, bool isOngoing) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSpacing.radiusInput),
      child: Image.asset(
        schedule.fallbackAsset,
        width: 50,
        height: 50,
        fit: BoxFit.cover,
      ),
    );
  }
}
