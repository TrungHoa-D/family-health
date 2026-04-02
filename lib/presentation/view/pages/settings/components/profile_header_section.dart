import 'package:easy_localization/easy_localization.dart';
import 'package:family_health/presentation/resources/app_spacing.dart';
import 'package:family_health/presentation/resources/colors.dart';
import 'package:family_health/presentation/resources/styles.dart';
import 'package:flutter/material.dart';

class ProfileHeaderSection extends StatelessWidget {
  final String name;
  final String email;

  const ProfileHeaderSection({
    super.key,
    required this.name,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.secondary, width: 3),
              ),
              child: ClipOval(
                child: Container(
                  color: AppColors.surface,
                  child: Center(
                    child: Text(
                      name.isNotEmpty ? name[0] : 'U',
                      style: AppStyles.displayLarge.copyWith(color: AppColors.primary),
                    ),
                  ),
                ),
              ),
            ),
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.white, width: 2),
              ),
              child: const Icon(Icons.edit, color: AppColors.white, size: 14),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Text(name, style: AppStyles.headlineMedium.copyWith(fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
        const SizedBox(height: 4),
        Text(email, style: AppStyles.bodyMedium.copyWith(color: AppColors.textSecondary)),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () {},
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'settings.edit_profile'.tr(),
                style: AppStyles.titleSmall.copyWith(color: AppColors.primary, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 4),
              const Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.primary),
            ],
          ),
        ),
      ],
    );
  }
}
