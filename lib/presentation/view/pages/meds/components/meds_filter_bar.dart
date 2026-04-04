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
  });
  final int selectedIndex;
  final Function(int) onSelected;

  @override
  Widget build(BuildContext context) {
    final filters = [
      'meds.filter_all'.tr(),
      'meds.filter_blood_pressure'.tr(),
      'meds.filter_diabetes'.tr(),
      'meds.filter_supplement'.tr(),
    ];

    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final isSelected = selectedIndex == index;
          return Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: ChoiceChip(
              label: Text(filters[index]),
              selected: isSelected,
              onSelected: (_) => onSelected(index),
              selectedColor: AppColors.primary,
              backgroundColor: Colors.grey[200],
              labelStyle: AppStyles.labelLarge.copyWith(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppSpacing.radiusButton),
                side: BorderSide.none,
              ),
              showCheckmark: false,
            ),
          );
        },
      ),
    );
  }
}
