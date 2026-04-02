import 'package:easy_localization/easy_localization.dart';
import 'package:family_health/presentation/resources/app_spacing.dart';
import 'package:family_health/presentation/resources/colors.dart';
import 'package:family_health/presentation/resources/styles.dart';
import 'package:family_health/presentation/view/pages/settings/settings_state.dart';
import 'package:family_health/presentation/view/widgets/app_card.dart';
import 'package:flutter/material.dart';

class RoutinesSection extends StatelessWidget {
  final List<DailyRoutine> routines;

  const RoutinesSection({super.key, required this.routines});

  @override
  Widget build(BuildContext context) {
    if (routines.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          child: Text(
            'settings.routines'.tr(),
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
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: routines.length,
            separatorBuilder: (context, index) => const Divider(height: 1, color: AppColors.border),
            itemBuilder: (context, index) {
              final item = routines[index];
              return _RoutineTile(item: item, isLast: index == routines.length - 1);
            },
          ),
        ),
      ],
    );
  }
}

class _RoutineTile extends StatelessWidget {
  final DailyRoutine item;
  final bool isLast;

  const _RoutineTile({required this.item, required this.isLast});

  IconData _getIconForTitle(String title) {
    final lower = title.toLowerCase();
    if (lower.contains('sáng')) return Icons.wb_sunny;
    if (lower.contains('trưa')) return Icons.restaurant;
    if (lower.contains('tối')) return Icons.restaurant_menu;
    if (lower.contains('ngủ')) return Icons.dark_mode;
    return Icons.schedule;
  }

  Color _getColorForTitle(String title) {
    final lower = title.toLowerCase();
    if (lower.contains('sáng')) return Colors.orange;
    if (lower.contains('trưa')) return AppColors.primary;
    if (lower.contains('tối')) return Colors.brown;
    if (lower.contains('ngủ')) return Colors.indigo;
    return AppColors.textSecondary;
  }

  @override
  Widget build(BuildContext context) {
    final iconColor = _getColorForTitle(item.title);
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(_getIconForTitle(item.title), color: iconColor),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.title, style: AppStyles.titleMedium),
                const SizedBox(height: 2),
                Text(item.subtitle, style: AppStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
          Text(
            item.time,
            style: AppStyles.titleMedium.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
