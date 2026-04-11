import 'package:easy_localization/easy_localization.dart';
import 'package:family_health/presentation/resources/app_spacing.dart';
import 'package:family_health/presentation/resources/colors.dart';
import 'package:family_health/presentation/resources/styles.dart';
import 'package:flutter/material.dart';

class MedsFilterBar extends StatelessWidget {
  const MedsFilterBar({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
    required this.filterLabels,
    this.onViewMore,
  });
  final int selectedIndex;
  final Function(int) onSelected;
  final List<String> filterLabels;
  final VoidCallback? onViewMore;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        itemCount: filterLabels.length + (onViewMore != null ? 1 : 0),
        itemBuilder: (context, index) {
          // Nút "Xem thêm" ở cuối
          if (index == filterLabels.length) {
            return Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: ActionChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('meds.view_more_categories'.tr()),
                    const SizedBox(width: 4),
                    const Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.primary),
                  ],
                ),
                onPressed: onViewMore,
                backgroundColor: AppColors.primary.withOpacity(0.1),
                labelStyle: AppStyles.labelLarge.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
                  side: BorderSide(color: AppColors.primary.withOpacity(0.3)),
                ),
              ),
            );
          }

          final isSelected = selectedIndex == index;
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: ChoiceChip(
              label: Text(filterLabels[index]),
              selected: isSelected,
              onSelected: (_) => onSelected(index),
              selectedColor: AppColors.primary,
              backgroundColor: Colors.transparent,
              labelStyle: AppStyles.labelLarge.copyWith(
                color: isSelected ? Colors.white : AppColors.primary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
                side: isSelected
                    ? BorderSide.none
                    : BorderSide(color: Colors.grey[300]!, width: 1),
              ),
              showCheckmark: false,
            ),
          );
        },
      ),
    );
  }
}
