import 'package:family_health/presentation/resources/app_spacing.dart';
import 'package:family_health/presentation/resources/colors.dart';
import 'package:family_health/presentation/resources/styles.dart';
import 'package:flutter/material.dart';

class CalendarStrip extends StatelessWidget {
  const CalendarStrip({
    super.key,
    required this.currentDate,
    required this.selectedDate,
    required this.onDateSelected,
  });
  final DateTime currentDate;
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  @override
  Widget build(BuildContext context) {
    // Generate 7 days: 2 before, today, 4 after
    final startDate = currentDate.subtract(const Duration(days: 2));
    final days =
        List.generate(7, (index) => startDate.add(Duration(days: index)));

    return SizedBox(
      height: 100, // accommodate scale-105 selected item
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.xs,
        ),
        scrollDirection: Axis.horizontal,
        itemCount: days.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
        itemBuilder: (context, index) {
          final date = days[index];
          final isSelected = date.year == selectedDate.year &&
              date.month == selectedDate.month &&
              date.day == selectedDate.day;

          // Vietnamese day of week (T2, T3... CN)
          String dayOfWeek;
          if (date.weekday == DateTime.sunday) {
            dayOfWeek = 'CN';
          } else {
            dayOfWeek = 'T${date.weekday + 1}';
          }

          return GestureDetector(
            onTap: () => onDateSelected(date),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 64,
              height: 96,
              transform: Matrix4.identity()..scale(isSelected ? 1.05 : 1.0),
              transformAlignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.surface,
                borderRadius: BorderRadius.circular(16),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : [],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    dayOfWeek.toUpperCase(),
                    style: AppStyles.labelSmall.copyWith(
                      color: isSelected
                          ? AppColors.white.withValues(alpha: 0.8)
                          : AppColors.textSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${date.day}',
                    style: AppStyles.headlineMedium.copyWith(
                      color:
                          isSelected ? AppColors.white : AppColors.textPrimary,
                    ),
                  ),
                  if (isSelected) ...[
                    const SizedBox(height: 6),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
