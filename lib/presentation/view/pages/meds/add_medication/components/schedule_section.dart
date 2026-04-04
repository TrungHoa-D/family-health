import 'package:easy_localization/easy_localization.dart';
import 'package:family_health/presentation/resources/app_spacing.dart';
import 'package:family_health/presentation/resources/colors.dart';
import 'package:family_health/presentation/resources/styles.dart';
import 'package:flutter/material.dart';

/// Section lịch trình & giám sát — Grid 2x2
/// Gồm: Người uống, Mốc thời gian, Độ lệch, Người giám sát
class ScheduleSection extends StatelessWidget {
  const ScheduleSection({
    super.key,
    required this.selectedUser,
    required this.anchorTime,
    required this.offset,
    required this.supervisor,
    required this.onUserChanged,
    required this.onAnchorTimeChanged,
    required this.onOffsetChanged,
    required this.onSupervisorChanged,
  });
  final String selectedUser;
  final String anchorTime;
  final String offset;
  final String supervisor;
  final ValueChanged<String> onUserChanged;
  final ValueChanged<String> onAnchorTimeChanged;
  final ValueChanged<String> onOffsetChanged;
  final ValueChanged<String> onSupervisorChanged;

  static const _users = ['Bố', 'Mẹ', 'Em', 'Ông nội'];
  static const _anchorTimes = [
    'Giờ ăn sáng',
    'Sau ăn sáng',
    'Giờ ăn trưa',
    'Sau ăn trưa',
    'Giờ ăn tối',
    'Sau ăn tối',
    'Giờ đi ngủ',
  ];
  static const _offsets = ['Trước 30p', 'Ngay lúc ăn', 'Sau 30p', 'Sau 1h'];
  static const _supervisors = ['Trung Hòa', 'Bố', 'Mẹ', 'Em'];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'meds.schedule_section'.tr(),
          style: AppStyles.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        // Grid 2x2
        Row(
          children: [
            Expanded(
              child: _ScheduleGridItem(
                label: 'meds.user_label'.tr(),
                value: selectedUser,
                items: _users,
                onChanged: onUserChanged,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _ScheduleGridItem(
                label: 'meds.anchor_time_label'.tr(),
                value: anchorTime,
                items: _anchorTimes,
                onChanged: onAnchorTimeChanged,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: _ScheduleGridItem(
                label: 'meds.offset_label'.tr(),
                value: offset,
                items: _offsets,
                onChanged: onOffsetChanged,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _ScheduleGridItem(
                label: 'meds.supervisor_label'.tr(),
                value: supervisor,
                items: _supervisors,
                onChanged: onSupervisorChanged,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Grid item — dropdown-like selector
class _ScheduleGridItem extends StatelessWidget {
  const _ScheduleGridItem({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });
  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showPicker(context),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm + 4,
          vertical: AppSpacing.sm + 4,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppSpacing.radiusInput),
          border: Border.all(
            color: AppColors.border,
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label.toUpperCase(),
              style: AppStyles.labelSmall.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
                fontSize: 10,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    value,
                    style: AppStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const Icon(
                  Icons.expand_more,
                  color: AppColors.textSecondary,
                  size: 16,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppSpacing.lg),
        ),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: AppSpacing.sm),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            ...items.map(
              (item) => ListTile(
                title: Text(
                  item,
                  style: AppStyles.bodyMedium.copyWith(
                    fontWeight:
                        item == value ? FontWeight.bold : FontWeight.normal,
                    color: item == value
                        ? AppColors.primary
                        : AppColors.textPrimary,
                  ),
                ),
                trailing: item == value
                    ? const Icon(Icons.check, color: AppColors.primary)
                    : null,
                onTap: () {
                  onChanged(item);
                  Navigator.pop(context);
                },
              ),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }
}
