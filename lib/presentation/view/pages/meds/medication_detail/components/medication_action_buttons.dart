import 'package:easy_localization/easy_localization.dart';
import 'package:family_health/presentation/resources/app_spacing.dart';
import 'package:family_health/presentation/resources/colors.dart';
import 'package:family_health/presentation/resources/styles.dart';
import 'package:flutter/material.dart';

/// 3 nút hành động hàng ngang: Sửa, Copy, Xóa
class MedicationActionButtons extends StatelessWidget {
  const MedicationActionButtons({
    super.key,
    this.onEdit,
    this.onCopy,
    this.onDelete,
  });
  final VoidCallback? onEdit;
  final VoidCallback? onCopy;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Sửa
        Expanded(
          child: _ActionButton(
            icon: Icons.edit,
            label: 'meds.action_edit'.tr(),
            backgroundColor: const Color(0xFFE5E2E1),
            textColor: AppColors.textSecondary,
            iconColor: AppColors.textSecondary,
            onTap: onEdit,
          ),
        ),
        const SizedBox(width: AppSpacing.sm + 4),

        // Copy
        Expanded(
          child: _ActionButton(
            icon: Icons.content_copy,
            label: 'meds.action_copy'.tr(),
            backgroundColor: const Color(0xFFE5E2E1),
            textColor: AppColors.textSecondary,
            iconColor: AppColors.textSecondary,
            onTap: onCopy,
          ),
        ),
        const SizedBox(width: AppSpacing.sm + 4),

        // Xóa
        Expanded(
          child: _ActionButton(
            icon: Icons.delete,
            label: 'meds.action_delete'.tr(),
            backgroundColor: const Color(0xFFFFDBD0),
            textColor: const Color(0xFF832600),
            iconColor: const Color(0xFFA33200),
            onTap: onDelete,
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
    required this.iconColor,
    this.onTap,
  });
  final IconData icon;
  final String label;
  final Color backgroundColor;
  final Color textColor;
  final Color iconColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusCard),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: iconColor),
              const SizedBox(width: AppSpacing.sm),
              Flexible(
                child: Text(
                  label,
                  style: AppStyles.labelLarge.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
