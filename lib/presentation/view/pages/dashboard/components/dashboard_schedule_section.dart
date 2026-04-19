import 'package:easy_localization/easy_localization.dart';
import 'package:family_health/presentation/resources/app_spacing.dart';
import 'package:family_health/presentation/resources/colors.dart';
import 'package:family_health/presentation/resources/styles.dart';
import 'package:family_health/presentation/view/widgets/app_card.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';

enum DashboardScheduleMode { ongoing, upcoming }

class DashboardScheduleSection extends StatefulWidget {
  const DashboardScheduleSection({
    super.key,
    required this.schedules,
    required this.title,
    this.mode = DashboardScheduleMode.upcoming,
  });
  final List<DashboardScheduleModel> schedules;
  final DashboardScheduleMode mode;
  final String title;

  @override
  State<DashboardScheduleSection> createState() =>
      _DashboardScheduleSectionState();
}

class _DashboardScheduleSectionState extends State<DashboardScheduleSection> {
  final PageController _pageController = PageController(viewportFraction: 0.85);
  Timer? _timer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    if (widget.schedules.length > 1) {
      _startAutoPlay();
    }
  }

  void _startAutoPlay() {
    _timer = Timer.periodic(const Duration(seconds: 10), (Timer timer) {
      if (_pageController.hasClients) {
        _currentPage++;
        if (_currentPage >= widget.schedules.length) {
          _currentPage = 0;
          _pageController.animateToPage(
            _currentPage,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        } else {
          _pageController.animateToPage(
            _currentPage,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeIn,
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.schedules.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: Text(
            widget.title,
            style: AppStyles.titleMedium.copyWith(fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        SizedBox(
          height: 96, // fixed height for page view
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.schedules.length,
            onPageChanged: (int page) {
              _currentPage = page;
            },
            itemBuilder: (context, index) {
              final schedule = widget.schedules[index];
              final isLast = index == widget.schedules.length - 1;
              return _ScheduleCard(
                schedule: schedule,
                mode: widget.mode,
                isLast: isLast,
              );
            },
          ),
        ),
      ],
    );
  }
}

class DashboardScheduleModel {
  DashboardScheduleModel({
    required this.title,
    required this.dateTime,
    required this.location,
    this.timeMode = 'from_to',
    this.endTime,
    this.mealTime,
    this.imageUrl,
    this.eventType = 'OTHER',
    this.onTap,
  });
  final String title;
  final DateTime dateTime;
  final String location;
  final String timeMode;
  final DateTime? endTime;
  final String? mealTime;
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
  const _ScheduleCard({
    required this.schedule,
    required this.mode,
    this.isLast = false,
  });
  final DashboardScheduleModel schedule;
  final DashboardScheduleMode mode;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final isOngoing = mode == DashboardScheduleMode.ongoing;
    final accentColor = isOngoing ? AppColors.success : AppColors.primary;

    return AppCard(
      margin: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,  // cân bằng cả 2 bên để căn giữa hoàn hảo
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
                  _getSubtitle(),
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

  String _getSubtitle() {
    String timeStr = '';
    if (schedule.timeMode == 'all_day') {
      timeStr = 'home.all_day'.tr(); // "Cả ngày"
    } else if (schedule.timeMode == 'meal_based') {
      String mealName = 'Bữa ăn';
      if (schedule.mealTime == 'breakfast')
        mealName = 'Bữa sáng';
      else if (schedule.mealTime == 'lunch')
        mealName = 'Bữa trưa';
      else if (schedule.mealTime == 'dinner') mealName = 'Bữa tối';
      timeStr = '$mealName (${DateFormat('HH:mm').format(schedule.dateTime)})';
    } else {
      if (schedule.endTime != null) {
        timeStr =
            'Từ ${DateFormat('HH:mm').format(schedule.dateTime)} đến ${DateFormat('HH:mm').format(schedule.endTime!)}';
      } else {
        timeStr = DateFormat('HH:mm').format(schedule.dateTime);
      }
    }

    if (schedule.location.isNotEmpty) {
      // Bỏ dấu chấm nếu text location rỗng tránh dư thừa
      return '$timeStr • ${schedule.location}';
    }
    return timeStr;
  }
}
